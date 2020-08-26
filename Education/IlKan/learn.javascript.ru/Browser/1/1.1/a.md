![](https://learn.javascript.ru/article/browser-environment/windowObjects.svg)

background be #05f

    <!doctype html>
    <html lang="en">

    <head>
    </head>

    <body>
        <script !src="">
            setTimeout(() => {
                document.body.style.backgroundColor = '#05f';
                setTimeout(() => location.href = "https://wikipedia.org", 3000)
            }, 3000);
            ;
        </script>
    </body>

    </html>