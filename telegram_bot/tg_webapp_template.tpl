<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
    <meta name="format-detection" content="telephone=no"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="MobileOptimized" content="176"/>
    <meta name="HandheldFriendly" content="True"/>
    <meta name="robots" content="noindex,nofollow"/>
    <title></title>
    <script src="https://cdn.myshm.ru/telegram/telegram-web-app-56.js"></script>
    <style>
        body {
            --bg-color: var(--tg-theme-bg-color, #fff);
            font-family: sans-serif;
            background-color: var(--bg-color);
            color: var(--tg-theme-text-color, #222);
            font-size: 14px;
            margin: 5;
            padding: 0;
            color-scheme: var(--tg-color-scheme);
        }

        iframe {
            border: none;
            width: 100%;
            height: 96vh;
        }

    </style>
</head>

<body class="">
<section id="main_section"></section>

<script type="application/javascript">
    const ShmPayApp = {
        initData        : Telegram.WebApp.initData || '',
        initDataUnsafe  : Telegram.WebApp.initDataUnsafe || {},
        MainButton      : Telegram.WebApp.MainButton,

        init(options) {
            Telegram.WebApp.ready();
            Telegram.WebApp.MainButton.setParams({
                text      : 'Закрыть',
                is_visible: true
            }).onClick(ShmPayApp.close);

            Telegram.WebApp.MainButton.showProgress();

            let urlParams = new URLSearchParams(window.location.search);
            let profile = urlParams.get('profile');
            let template = urlParams.get('tpl');

            let xhrURL = new URL('{{ config.api.url }}/shm/v1/telegram/webapp/auth');
            xhrURL.searchParams.set('profile', profile );
            xhrURL.searchParams.set('initData', Telegram.WebApp.initData);

            let xhr = new XMLHttpRequest();
            xhr.open('GET', xhrURL);
            xhr.send();
            xhr.onload = function() {
                if (xhr.status === 200) {
                    ShmPayApp.session_id = JSON.parse(xhr.response).session_id;
                    ShmPayApp.insert_template(template);
                    Telegram.WebApp.MainButton.hideProgress();
                    Telegram.WebApp.expand();
                } else {
                    Telegram.WebApp.showAlert("Ошибка авторизации");
                    Telegram.WebApp.close();
                }
            };
        },
        expand() {
            Telegram.WebApp.expand();
        },
        close() {
            Telegram.WebApp.close();
        },
        insert_template(template) {
            let ifrm = document.createElement('iframe');
            ifrm.setAttribute("src", "{{ config.api.url }}/shm/v1/template/" + template + "?format=html&session_id=" + ShmPayApp.session_id );
            document.getElementById("main_section").appendChild(ifrm);
        },
    }
</script>

<script type="application/javascript">
    ShmPayApp.init();
</script>

</body>
</html>
