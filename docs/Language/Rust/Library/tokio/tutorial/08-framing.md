---
title: "Framing (التأطير)"
---

سنقوم الآن بتطبيق ما تعلمناه للتو حول الإدخال/الإخراج (I/O) وتنفيذ طبقة التأطير (framing layer) لـ Mini-Redis. التأطير هو عملية أخذ تدفق بايت (byte stream) وتحويله إلى تدفق إطارات (stream of frames). الإطار هو وحدة بيانات يتم إرسالها بين نظيرين (peers). يتم تعريف إطار بروتوكول Redis على النحو التالي:

```rust
use bytes::Bytes;

enum Frame {
    Simple(String),
    Error(String),
    Integer(u64),
    Bulk(Bytes),
    Null,
    Array(Vec<Frame>),
}
```

لاحظ كيف يتكون الإطار من البيانات فقط بدون أي دلالات (semantics). يحدث تحليل الأوامر (command parsing) والتنفيذ على مستوى أعلى.

بالنسبة لـ HTTP، قد يبدو الإطار كما يلي:

```rust
# use bytes::Bytes;
# type Method = ();
# type Uri = ();
# type Version = ();
# type HeaderMap = ();
# type StatusCode = ();
enum HttpFrame {
    RequestHead {
        method: Method,
        uri: Uri,
        version: Version,
        headers: HeaderMap,
    },
    ResponseHead {
        status: StatusCode,
        version: Version,
        headers: HeaderMap,
    },
    BodyChunk {
        chunk: Bytes,
    },
}
```

لتنفيذ التأطير لـ Mini-Redis، سنقوم بتطبيق بنية `Connection` التي تغلف `TcpStream` وتقرأ/تكتب قيم `mini_redis::Frame`.

```rust
use tokio::net::TcpStream;
use mini_redis::{Frame, Result};

struct Connection {
    stream: TcpStream,
    // ... other fields here
}

impl Connection {
    /// Read a frame from the connection.
    /// 
    /// Returns `None` if EOF is reached
    pub async fn read_frame(&mut self)
        -> Result<Option<Frame>>
    {
        // implementation here
# unimplemented!();
    }

    /// Write a frame to the connection.
    pub async fn write_frame(&mut self, frame: &Frame)
        -> Result<()>
    {
        // implementation here
# unimplemented!();
    }
}
```

يمكنك العثور على تفاصيل بروتوكول Redis السلكي (wire protocol) [هنا][proto]. يمكن العثور على كود `Connection` الكامل [هنا][full].

[proto]: https://redis.io/topics/protocol
[full]: https://github.com/tokio-rs/mini-redis/blob/tutorial/src/connection.rs

# Buffered reads (القراءات المخزنة مؤقتًا)

تنتظر طريقة `read_frame` حتى يتم استلام إطار كامل قبل الإرجاع. قد تُرجع استدعاء واحد لـ `TcpStream::read()` كمية عشوائية من البيانات. يمكن أن تحتوي على إطار كامل، أو إطار جزئي، أو إطارات متعددة. إذا تم استلام إطار جزئي، يتم تخزين البيانات مؤقتًا ويتم قراءة المزيد من البيانات من المقبس (socket). إذا تم استلام إطارات متعددة، يتم إرجاع الإطار الأول ويتم تخزين بقية البيانات مؤقتًا حتى الاستدعاء التالي لـ `read_frame`.

إذا لم تكن قد قمت بذلك بالفعل، فأنشئ ملفًا جديدًا يسمى `connection.rs`.

```bash
touch src/connection.rs
```

لتنفيذ ذلك، تحتاج `Connection` إلى حقل مخزن مؤقت للقراءة (read buffer field). تُقرأ البيانات من المقبس إلى المخزن المؤقت للقراءة. عندما يتم تحليل إطار، تتم إزالة البيانات المقابلة من المخزن المؤقت.

سنستخدم [`BytesMut`][BytesMutStruct] كنوع المخزن المؤقت. هذه نسخة قابلة للتغيير من [`Bytes`][BytesStruct].

```rust
use bytes::BytesMut;
use tokio::net::TcpStream;

pub struct Connection {
    stream: TcpStream,
    buffer: BytesMut,
}

impl Connection {
    pub fn new(stream: TcpStream) -> Connection {
        Connection {
            stream,
            // Allocate the buffer with 4kb of capacity.
            buffer: BytesMut::with_capacity(4096),
        }
    }
}
```

بعد ذلك، نقوم بتطبيق طريقة `read_frame()`.

```rust
use tokio::io::AsyncReadExt;
use bytes::Buf;
use mini_redis::Result;

# struct Connection {
#   stream: tokio::net::TcpStream,
#   buffer: bytes::BytesMut,
# }
# struct Frame {}
# impl Connection {
pub async fn read_frame(&mut self)
    -> Result<Option<Frame>>
{
    loop {
        // Attempt to parse a frame from the buffered data. If
        // enough data has been buffered, the frame is
        // returned.
        if let Some(frame) = self.parse_frame()? {
            return Ok(Some(frame));
        }

        // There is not enough buffered data to read a frame.
        // Attempt to read more data from the socket.
        //
        // On success, the number of bytes is returned. `0`
        // indicates "end of stream".
        if 0 == self.stream.read_buf(&mut self.buffer).await? {
            // The remote closed the connection. For this to be
            // a clean shutdown, there should be no data in the
            // read buffer. If there is, this means that the
            // peer closed the socket while sending a frame.
            if self.buffer.is_empty() {
                return Ok(None);
            } else {
                return Err("connection reset by peer".into());
            }
        }
    }
}
# fn parse_frame(&self) -> Result<Option<Frame>> { unimplemented!() }
# }
```

دعنا نحلل هذا. تعمل طريقة `read_frame` في حلقة. أولاً، يتم استدعاء `self.parse_frame()`. سيحاول هذا تحليل إطار redis من `self.buffer`. إذا كانت هناك بيانات كافية لتحليل إطار، يتم إرجاع الإطار إلى المتصل بـ `read_frame()`. وإلا، فإننا نحاول قراءة المزيد من البيانات من المقبس إلى المخزن المؤقت. بعد قراءة المزيد من البيانات، يتم استدعاء `parse_frame()` مرة أخرى. هذه المرة، إذا تم استلام بيانات كافية، فقد ينجح التحليل.

عند القراءة من التدفق (stream)، تشير القيمة المرجعة `0` إلى أنه لن يتم استلام المزيد من البيانات من النظير. إذا كان المخزن المؤقت للقراءة لا يزال يحتوي على بيانات، فهذا يشير إلى أنه تم استلام إطار جزئي وأن الاتصال يتم إنهاؤه فجأة. هذه حالة خطأ ويتم إرجاع `Err`.

[BytesMutStruct]: https://docs.rs/bytes/1/bytes/struct.BytesMut.html
[BytesStruct]: https://docs.rs/bytes/1/bytes/struct.Bytes.html

## The `Buf` trait (سمة Buf)

عند القراءة من التدفق، يتم استدعاء `read_buf`. تأخذ هذه النسخة من دالة القراءة قيمة تُطبق [`BufMut`] من crate [`bytes`].

أولاً، دعنا نفكر في كيفية تنفيذ نفس حلقة القراءة باستخدام `read()`. يمكن استخدام `Vec<u8>` بدلاً من `BytesMut`.

```rust
use tokio::net::TcpStream;

pub struct Connection {
    stream: TcpStream,
    buffer: Vec<u8>,
    cursor: usize,
}

impl Connection {
    pub fn new(stream: TcpStream) -> Connection {
        Connection {
            stream,
            // Allocate the buffer with 4kb of capacity.
            buffer: vec![0; 4096],
            cursor: 0,
        }
    }
}
```

ودالة `read_frame()` على `Connection`:

```rust
use mini_redis::{Frame, Result};

# use tokio::io::AsyncReadExt;
# pub struct Connection {
#     stream: tokio::net::TcpStream,
#     buffer: Vec<u8>,
#     cursor: usize,
# }
# impl Connection {
pub async fn read_frame(&mut self)
    -> Result<Option<Frame>>
{
    loop {
        if let Some(frame) = self.parse_frame()? {
            return Ok(Some(frame));
        }

        // Ensure the buffer has capacity
        if self.buffer.len() == self.cursor {
            // Grow the buffer
            self.buffer.resize(self.cursor * 2, 0);
        }

        // Read into the buffer, tracking the number
        // of bytes read
        let n = self.stream.read(
            &mut self.buffer[self.cursor..]).await?;

        if 0 == n {
            if self.cursor == 0 {
                return Ok(None);
            } else {
                return Err("connection reset by peer".into());
            }
        } else {
            // Update our cursor
            self.cursor += n;
        }
    }
}
# fn parse_frame(&mut self) -> Result<Option<Frame>> { unimplemented!() }
# }
```

عند العمل مع مصفوفات البايت (byte arrays) و`read`، يجب علينا أيضًا الحفاظ على مؤشر (cursor) يتتبع كمية البيانات التي تم تخزينها مؤقتًا. يجب علينا التأكد من تمرير الجزء الفارغ من المخزن المؤقت إلى `read()`. وإلا، فسنقوم بالكتابة فوق البيانات المخزنة مؤقتًا. إذا امتلأ المخزن المؤقت لدينا، يجب علينا زيادة حجم المخزن المؤقت لمواصلة القراءة. في `parse_frame()` (غير متضمنة)، سنحتاج إلى تحليل البيانات الموجودة في `self.buffer[..self.cursor]`.

نظرًا لأن إقران مصفوفة بايت بمؤشر أمر شائع جدًا، فإن crate `bytes` يوفر تجريدًا يمثل مصفوفة بايت ومؤشرًا. يتم تطبيق سمة `Buf` بواسطة الأنواع التي يمكن قراءة البيانات منها. يتم تطبيق سمة `BufMut` بواسطة الأنواع التي يمكن كتابة البيانات فيها. عند تمرير `T: BufMut` إلى `read_buf()`، يتم تحديث المؤشر الداخلي للمخزن المؤقت تلقائيًا بواسطة `read_buf`. لهذا السبب، في نسختنا من `read_frame`، لا نحتاج إلى إدارة مؤشرنا الخاص.

بالإضافة إلى ذلك، عند استخدام `Vec<u8>`، يجب **تهيئة** المخزن المؤقت. `vec![0; 4096]` يخصص مصفوفة من 4096 بايت ويكتب صفرًا في كل إدخال. عند تغيير حجم المخزن المؤقت، يجب أيضًا تهيئة السعة الجديدة بأصفار. عملية التهيئة ليست مجانية. عند العمل مع `BytesMut` و`BufMut`، تكون السعة **غير مهيأة**. يمنعنا تجريد `BytesMut` من قراءة الذاكرة غير المهيأة. يتيح لنا هذا تجنب خطوة التهيئة.

[`BufMut`]: https://docs.rs/bytes/1/bytes/buf/trait.BufMut.html
[`bytes`]: https://docs.rs/bytes/

# Parsing (التحليل)

الآن، دعنا نلقي نظرة على دالة `parse_frame()`. يتم التحليل على خطوتين.

1. التأكد من تخزين إطار كامل مؤقتًا والعثور على فهرس نهاية الإطار.
2. تحليل الإطار.

يوفر لنا crate `mini-redis` دالة لكل من هاتين الخطوتين:

1. [`Frame::check`](https://docs.rs/mini-redis/0.4/mini_redis/frame/enum.Frame.html#method.check)
2. [`Frame::parse`](https://docs.rs/mini-redis/0.4/mini_redis/frame/enum.Frame.html#method.parse)

سنعيد استخدام تجريد `Buf` للمساعدة أيضًا. يتم تمرير `Buf` إلى `Frame::check`. بينما تقوم دالة `check` بتكرار المخزن المؤقت الذي تم تمريره، سيتقدم المؤشر الداخلي. عندما تُرجع `check`، يشير المؤشر الداخلي للمخزن المؤقت إلى نهاية الإطار.

بالنسبة لنوع `Buf`، سنستخدم [`std::io::Cursor<&[u8]>`][`Cursor`].

```rust
use mini_redis::{Frame, Result};
use mini_redis::frame::Error::Incomplete;
use bytes::Buf;
use std::io::Cursor;

# pub struct Connection {
#     stream: tokio::net::TcpStream,
#     buffer: bytes::BytesMut,
# }
# impl Connection {
fn parse_frame(&mut self)
    -> Result<Option<Frame>>
{
    // Create the `T: Buf` type.
    let mut buf = Cursor::new(&self.buffer[..]);

    // Check whether a full frame is available
    match Frame::check(&mut buf) {
        Ok(_) => {
            // Get the byte length of the frame
            let len = buf.position() as usize;

            // Reset the internal cursor for the
            // call to `parse`.
            buf.set_position(0);

            // Parse the frame
            let frame = Frame::parse(&mut buf)?;

            // Discard the frame from the buffer
            self.buffer.advance(len);

            // Return the frame to the caller.
            Ok(Some(frame))
        }
        // Not enough data has been buffered
        Err(Incomplete) => Ok(None),
        // An error was encountered
        Err(e) => Err(e.into()),
    }
}
# }
```

يمكن العثور على دالة [`Frame::check`][check] الكاملة [هنا][check]. لن نغطيها بالكامل.

الشيء المهم الذي يجب ملاحظته هو أنه يتم استخدام واجهات برمجة التطبيقات (APIs) لـ `Buf` بأسلوب 
"مكرر البايت" (byte iterator). هذه تجلب البيانات وتقدم المؤشر الداخلي. على سبيل المثال، لتحليل إطار، يتم فحص البايت الأول لتحديد نوع الإطار. الدالة المستخدمة هي [`Buf::get_u8`]. هذه تجلب البايت في موضع المؤشر الحالي وتقدم المؤشر بمقدار واحد.

توجد طرق أكثر فائدة في سمة [`Buf`]. تحقق من [وثائق API][`Buf`] لمزيد من التفاصيل.

[check]: https://github.com/tokio-rs/mini-redis/blob/tutorial/src/frame.rs#L65-L103
[`Buf::get_u8`]: https://docs.rs/bytes/1/bytes/buf/trait.Buf.html#method.get_u8
[`Buf`]: https://docs.rs/bytes/1/bytes/buf/trait.Buf.html
[`Cursor`]: https://doc.rust-lang.org/stable/std/io/struct.Cursor.html

# Buffered writes (الكتابات المخزنة مؤقتًا)

النصف الآخر من واجهة برمجة تطبيقات التأطير هو دالة `write_frame(frame)`. تكتب هذه الدالة إطارًا كاملاً إلى المقبس. لتقليل استدعاءات نظام `write`، سيتم تخزين الكتابات مؤقتًا. يتم الاحتفاظ بمخزن مؤقت للكتابة ويتم ترميز الإطارات إلى هذا المخزن المؤقت قبل كتابتها إلى المقبس. ومع ذلك، على عكس `read_frame()`، لا يتم دائمًا تخزين الإطار بأكمله مؤقتًا في مصفوفة بايت قبل الكتابة إلى المقبس.

ضع في اعتبارك إطار تدفق مجمع (bulk stream frame). القيمة التي يتم كتابتها هي `Frame::Bulk(Bytes)`. تنسيق السلك (wire format) لإطار مجمع هو رأس إطار، يتكون من الحرف `$` متبوعًا بطول البيانات بالبايت. غالبية الإطار هي محتويات قيمة `Bytes`. إذا كانت البيانات كبيرة، فإن نسخها إلى مخزن مؤقت وسيط سيكون مكلفًا.

لتنفيذ الكتابات المخزنة مؤقتًا، سنستخدم بنية [`BufWriter`][buf-writer]. يتم تهيئة هذه البنية بـ `T: AsyncWrite` وتُطبق `AsyncWrite` نفسها. عندما يتم استدعاء `write` على `BufWriter`، لا تذهب الكتابة مباشرة إلى الكاتب الداخلي، بل إلى مخزن مؤقت. عندما يمتلئ المخزن المؤقت، يتم تفريغ المحتويات إلى الكاتب الداخلي ويتم مسح المخزن المؤقت الداخلي. توجد أيضًا تحسينات تسمح بتجاوز المخزن المؤقت في حالات معينة.

لن نحاول تنفيذًا كاملاً لـ `write_frame()` كجزء من البرنامج التعليمي. راجع التنفيذ الكامل [هنا][write-frame].

أولاً، يتم تحديث بنية `Connection`:

```rust
use tokio::io::BufWriter;
use tokio::net::TcpStream;
use bytes::BytesMut;

pub struct Connection {
    stream: BufWriter<TcpStream>,
    buffer: BytesMut,
}

impl Connection {
    pub fn new(stream: TcpStream) -> Connection {
        Connection {
            stream: BufWriter::new(stream),
            buffer: BytesMut::with_capacity(4096),
        }
    }
}
```

بعد ذلك، يتم تطبيق `write_frame()`.

```rust
use tokio::io::{self, AsyncWriteExt};
use mini_redis::Frame;

# struct Connection {
#   stream: tokio::io::BufWriter<tokio::net::TcpStream>,
#   buffer: bytes::BytesMut,
# }
# impl Connection {
async fn write_frame(&mut self, frame: &Frame)
    -> io::Result<()>
{
    match frame {
        Frame::Simple(val) => {
            self.stream.write_u8(b'+').await?;
            self.stream.write_all(val.as_bytes()).await?;
            self.stream.write_all(b"\r\n").await?;
        }
        Frame::Error(val) => {
            self.stream.write_u8(b'-').await?;
            self.stream.write_all(val.as_bytes()).await?;
            self.stream.write_all(b"\r\n").await?;
        }
        Frame::Integer(val) => {
            self.stream.write_u8(b':').await?;
            self.write_decimal(*val).await?;
        }
        Frame::Null => {
            self.stream.write_all(b"$-1\r\n").await?;
        }
        Frame::Bulk(val) => {
            let len = val.len();

            self.stream.write_u8(b'$').await?;
            self.write_decimal(len as u64).await?;
            self.stream.write_all(val).await?;
            self.stream.write_all(b"\r\n").await?;
        }
        Frame::Array(_val) => unimplemented!(),
    }

    self.stream.flush().await;

    Ok(())
}
# async fn write_decimal(&mut self, val: u64) -> io::Result<()> { unimplemented!() }
# }
```

الدوال المستخدمة هنا مقدمة بواسطة [`AsyncWriteExt`]. وهي متاحة على `TcpStream` أيضًا، ولكن لن يكون من المستحسن إصدار كتابات بايت واحد بدون المخزن المؤقت الوسيط.

* [`write_u8`] تكتب بايت واحدًا إلى الكاتب.
* [`write_all`] تكتب الشريحة بأكملها إلى الكاتب.
* [`write_decimal`] يتم تطبيقها بواسطة mini-redis.

تنتهي الدالة باستدعاء `self.stream.flush().await`. نظرًا لأن `BufWriter` يخزن الكتابات في مخزن مؤقت وسيط، فإن استدعاءات `write` لا تضمن كتابة البيانات إلى المقبس. قبل الإرجاع، نريد كتابة الإطار إلى المقبس. يؤدي استدعاء `flush()` إلى كتابة أي بيانات معلقة في المخزن المؤقت إلى المقبس.

بديل آخر هو **عدم** استدعاء `flush()` في `write_frame()`. بدلاً من ذلك، توفير دالة `flush()` على `Connection`. سيسمح هذا للمتصل بوضع العديد من الإطارات الصغيرة في قائمة الانتظار في المخزن المؤقت للكتابة ثم كتابتها جميعًا إلى المقبس باستدعاء نظام `write` واحد. يؤدي القيام بذلك إلى تعقيد واجهة برمجة تطبيقات `Connection`. البساطة هي أحد أهداف Mini-Redis، لذلك قررنا تضمين استدعاء `flush().await` في `fn write_frame()`.

[buf-writer]: https://docs.rs/tokio/1/tokio/io/struct.BufWriter.html
[write-frame]: https://github.com/tokio-rs/mini-redis/blob/tutorial/src/connection.rs#L159-L184
[`AsyncWriteExt`]: https://docs.rs/tokio/1/tokio/io/trait.AsyncWriteExt.html
[`write_u8`]: https://docs.rs/tokio/1/tokio/io/trait.AsyncWriteExt.html#method.write_u8
[`write_all`]: https://docs.rs/tokio/1/tokio/io/trait.AsyncWriteExt.html#method.write_all
[`write_decimal`]: https://github.com/tokio-rs/mini-redis/blob/tutorial/src/connection.rs#L225-L238
