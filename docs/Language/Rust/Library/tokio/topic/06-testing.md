---
title: "Unit Testing (اختبار الوحدات)"
---

الغرض من هذه الصفحة هو تقديم نصائح حول كيفية كتابة اختبارات وحدات (unit tests) مفيدة في التطبيقات غير المتزامنة (asynchronous applications).

## Pausing and resuming time in tests (إيقاف واستئناف الوقت في الاختبارات)

أحيانًا، ينتظر الكود غير المتزامن صراحةً عن طريق استدعاء [`tokio::time::sleep`] أو الانتظار على [`tokio::time::Interval::tick`]. يمكن أن يصبح اختبار السلوك القائم على الوقت (على سبيل المثال، التراجع الأسي (exponential backoff)) مرهقًا عندما يبدأ اختبار الوحدة في العمل ببطء شديد. ومع ذلك، داخليًا، تدعم وظائف Tokio المتعلقة بالوقت إيقاف واستئناف الوقت. يؤدي إيقاف الوقت إلى أن أي future متعلق بالوقت قد يصبح جاهزًا مبكرًا. شرط حل الـ future المتعلق بالوقت مبكرًا هو عدم وجود أي futures أخرى قد تصبح جاهزة. هذا بشكل أساسي يسرع الوقت عندما يكون الـ future الوحيد الذي يتم انتظاره متعلقًا بالوقت:

```rust
#[tokio::test]
async fn paused_time() {
    tokio::time::pause();
    let start = std::time::Instant::now();
    tokio::time::sleep(Duration::from_millis(500)).await;
    println!("{:?}ms", start.elapsed().as_millis());
}
```

يطبع هذا الكود `0ms` على جهاز معقول.

بالنسبة لاختبارات الوحدات، غالبًا ما يكون من المفيد التشغيل مع وقت متوقف طوال الوقت. يمكن تحقيق ذلك ببساطة عن طريق تعيين وسيط الماكرو `start_paused` إلى `true`:

```rust
#[tokio::test(start_paused = true)]
async fn paused_time() {
    let start = std::time::Instant::now();
    tokio::time::sleep(Duration::from_millis(500)).await;
    println!("{:?}ms", start.elapsed().as_millis());
}
```

ضع في اعتبارك أن سمة `start_paused` تتطلب ميزة tokio `test-util`. راجع [tokio::test "Configure the runtime to start with time paused"](https://docs.rs/tokio/latest/tokio/attr.test.html#configure-the-runtime-to-start-with-time-paused) لمزيد من التفاصيل.

بالطبع، يتم الحفاظ على الترتيب الزمني لحل الـ future، حتى عند استخدام futures مختلفة متعلقة بالوقت:

```rust
#[tokio::test(start_paused = true)]
async fn interval_with_paused_time() {
    let mut interval = interval(Duration::from_millis(300));
    let _ = timeout(Duration::from_secs(1), async move {
        loop {
            interval.tick().await;
            println!("Tick!");
        }
    })
    .await;
}
```

يطبع هذا الكود على الفور `"Tick!"` بالضبط 4 مرات.

[`tokio::time::Interval::tick`]: https://docs.rs/tokio/1/tokio/time/struct.Interval.html#method.tick
[`tokio::time::sleep`]: https://docs.rs/tokio/1/tokio/time/fn.sleep.html

## Mocking using [`AsyncRead`] and [`AsyncWrite`] (المحاكاة باستخدام AsyncRead و AsyncWrite)

يتم تطبيق السمات العامة للقراءة والكتابة بشكل غير متزامن ([`AsyncRead`] و[`AsyncWrite`]) بواسطة، على سبيل المثال، المقابس (sockets). يمكن استخدامها لمحاكاة الإدخال/الإخراج (I/O) الذي يتم بواسطة مقبس.

ضع في اعتبارك، للإعداد، حلقة خادم TCP البسيطة هذه:

```rust
use tokio::net::TcpListener;

#[tokio::main]
async fn main() {
    # if true { return }
    let listener = TcpListener::bind("127.0.0.1:8080").await.unwrap();
    loop {
        let Ok((mut socket, _)) = listener.accept().await else {
            eprintln!("Failed to accept client");
            continue;
        };

        tokio::spawn(async move {
            let (reader, writer) = socket.split();
            // Run some client connection handler, for example:
            // handle_connection(reader, writer)
                // .await
                // .expect("Failed to handle connection");
        });
    }
}
```

هنا، يتم خدمة كل اتصال عميل TCP بواسطة مهمة tokio المخصصة له. تمتلك هذه المهمة قارئًا وكاتبًا، وهما [`split`] من [`TcpStream`].

الآن، ضع في اعتبارك مهمة معالج العميل الفعلية، وخاصة شرط `where` في توقيع الدالة:

```rust
use tokio::io::{AsyncBufReadExt, AsyncRead, AsyncWrite, AsyncWriteExt, BufReader};

async fn handle_connection<Reader, Writer>(
    reader: Reader,
    mut writer: Writer,
) -> std::io::Result<()>
where
    Reader: AsyncRead + Unpin,
    Writer: AsyncWrite + Unpin,
{
    let mut line = String::new();
    let mut reader = BufReader::new(reader);

    loop {
        if let Ok(bytes_read) = reader.read_line(&mut line).await {
            if bytes_read == 0 {
                break Ok(());
            }
            writer
                .write_all(format!("Thanks for your message.\r\n").as_bytes())
                .await
                .unwrap();
        }
        line.clear();
    }
}
```

بشكل أساسي، يتم خدمة القارئ والكاتب المعطيين، اللذين يُطبقان [`AsyncRead`] و[`AsyncWrite`]، بشكل تسلسلي. لكل سطر مستلم، يرد المعالج بـ `"Thanks for your message."`.

لاختبار وحدة معالج اتصال العميل، يمكن استخدام [`tokio_test::io::Builder`] كمحاكاة (mock):

```rust
# use tokio::io::{AsyncBufReadExt, AsyncRead, AsyncWrite, AsyncWriteExt, BufReader};
# 
# async fn handle_connection<Reader, Writer>(
#     reader: Reader,
#     mut writer: Writer,
# ) -> std::io::Result<()>
# where
#     Reader: AsyncRead + Unpin,
#     Writer: AsyncWrite + Unpin,
# {
#     let mut line = String::new();
#     let mut reader = BufReader::new(reader);
#
#     loop {
#         if let Ok(bytes_read) = reader.read_line(&mut line).await {
#             if bytes_read == 0 {
#                 break Ok(());
#             }
#             writer
#                 .write_all(format!("Thanks for your message.\r\n").as_bytes())
#                 .await
#                 .unwrap();
#         }
#         line.clear();
#     }
# }
#
#[tokio::test]
async fn client_handler_replies_politely() {
    let reader = tokio_test::io::Builder::new()
        .read(b"Hi there\r\n")
        .read(b"How are you doing?\r\n")
        .build();
    let writer = tokio_test::io::Builder::new()
        .write(b"Thanks for your message.\r\n")
        .write(b"Thanks for your message.\r\n")
        .build();
    let _ = handle_connection(reader, writer).await;
}
```

[`AsyncRead`]: https://docs.rs/tokio/latest/tokio/io/trait.AsyncRead.html
[`AsyncWrite`]: https://docs.rs/tokio/latest/tokio/io/trait.AsyncWrite.html
[`split`]: https://docs.rs/tokio/latest/tokio/net/struct.TcpStream.html#method.split
[`TcpStream`]: https://docs.rs/tokio/latest/tokio/net/struct.TcpStream.html
[`tokio_test::io::Builder`]: https://docs.rs/tokio-test/latest/tokio_test/io/struct.Builder.html
