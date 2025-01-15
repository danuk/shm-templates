Админ Меню
Добавить в кейс <% CASE ['/start', '/menu', '🌍 Главное Меню', '🔄 Обновить'] %> он  выглядит у меня так  в  любое место 

				{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin'; }}
                [
                    {
                        "text": "👨‍💻 Меню {{ menuRole = (user.settings.role == 'admin' ? 'администратора' : 'модератора'); menuRole; }}",
                        "callback_data": "admin:menu"
                    }
                ],
                {{ END }}

теперь идем  в SHM > Скписок > Выбираем пользователя > settings и  добавляем role: admin

Вставить до <% END %>

<% CASE 'admin:menu' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin'; }}
{{ TEXT = BLOCK }}
<b>Меню {{ role = (user.settings.role == 'admin' ? 'Администратора' : 'Модератора'); role; }}</b>

🛑 <i>Будьте осторожны с выбором действий!</i>

{{ END }}
{
    "sendMessage": {
        "message_id": {{ message.message_id }},
        "parse_mode": "HTML",
        "text": "{{ TEXT.replace('\n','\n') }}",
        "reply_markup": {
            "inline_keyboard": [
                [
                    {
                        "text": "👥 Управление пользователями",
                        "callback_data": "admin:users:list"
                    },
                    {
                        "text": "🏠 Главное меню",
                        "callback_data": "/menu"
                    }
                ],
                {{ IF user.settings.role == 'admin' || (user.settings.role == 'moderator' && user.settings.moderate.settings == 1 )}}
                [
                    {
                        "text": "⚙️ Настройки бота",
                        "callback_data": "admin:settings"
                    }
                ],
                {{ END }}
                [
                    {
                        "text": "🏠 Главное меню",
                        "callback_data": "/menu"
                    }
                ]
            ]
        }
    }
}
{{ END }}



<% CASE 'admin:settings' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin' }}
{{ TEXT = BLOCK }}
<b>Конфигурация бота</b>

Запретить оформления новых ключей, если есть неоплаченные: {{ notPaidStatus = (checkNotPaidServices == 0 ? '⭕️ Выключено' : '🟢 Включено'); notPaidStatus; }}

Тип сообщений: {{ messageTypeStatus = (defaultMessageType == 'editMessageText' ? '✏️ Редактирование' : '🆕 Новое сообщение'); messageTypeStatus; }}
{{ END }}

{
    "sendMessage": {
        "parse_mode": "HTML",
        "text": "{{ TEXT.replace('\n','\n') }}",
        "reply_markup": {
            "inline_keyboard": [
                [
                    {
                        "text": "Изменить запрет оформления",
                        "callback_data": "admin:settings:change_notpaid"
                    }
                ],
                [
                    {
                        "text": "Изменить тип сообщений",
                        "callback_data": "admin:settings:change_msg"
                    }
                ],
                [
                    {
                        "text": "👨‍💻 Меню {{ menuRole = (user.settings.role == 'admin' ? 'администратора' : 'модератора'); menuRole; }}",
                        "callback_data": "admin:menu"
                    },
                    {
                        "text": "🏠 Главное меню",
                        "callback_data": "/menu"
                    }
                ]
            ]
        }
    }
}
{{ END }}


<% CASE 'admin:settings:change' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin' }}
{{ TEXT = BLOCK }}
<b>Конфигурация бота</b>

Запретить оформления новых ключей, если есть неоплаченные: {{ notPaidStatus = (checkNotPaidServices == 0 ? '⭕️ Выключено' : '🟢 Включено'); notPaidStatus; }}

Тип сообщений: {{ messageTypeStatus = (defaultMessageType == 'editMessageText' ? '✏️ Редактирование' : '🆕 Новое сообщение'); messageTypeStatus; }}
{{ END }}

{
    "sendMessage": {
        "parse_mode": "HTML",
        "text": "{{ TEXT.replace('\n','\n') }}",
        "reply_markup": {
            "inline_keyboard": [
                [
                    {
                        "text": "Изменить запрет оформления",
                        "callback_data": "admin:settings:change_notpaid"
                    }
                ],
                [
                    {
                        "text": "Изменить тип сообщений",
                        "callback_data": "admin:settings:change_msg"
                    }
                ],
                [
                    {
                        "text": "👨‍💻 Меню {{ menuRole = (user.settings.role == 'admin' ? 'администратора' : 'модератора'); menuRole; }}",
                        "callback_data": "admin:menu"
                    },
                    {
                        "text": "🏠 Главное меню",
                        "callback_data": "/menu"
                    }
                ]
            ]
        }
    }
}
{{ END }}

<% CASE 'admin:settings:change' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin' }}

{{ IF args.0 == 'notpaid' }}
{{      
        IF checkNotPaidServices == 0;
            ret = user.id(1).storage.save('bot_configuration', 'checkNotPaidServices' => 1, 'messageType' => defaultMessageType, 'menuCmd' => mainMenuCmd );
        ELSIF checkNotPaidServices == 1;
            ret = user.id(1).storage.save('bot_configuration', 'checkNotPaidServices' => 0, 'messageType' => defaultMessageType, 'menuCmd' => mainMenuCmd );
        END;
}}
{
    "answerCallbackQuery": {
         "callback_query_id": {{ callback_query.id }},
         "parse_mode":"HTML",
         "text": "✅ Запрет оформления новых ключей изменен!",
        "show_alert": true
     }
},
{
    "shmRedirectCallback": {
        "callback_data": "admin:settings"
    }
}
{{ ELSIF args.0 == 'msg' }}
{{
    IF defaultMessageType == 'sendMessage';
        ret = user.id(1).storage.save('bot_configuration', 'checkNotPaidServices' => checkNotPaidServices, 'messageType' => 'editMessageText', 'menuCmd' => 'menu' );
    ELSIF defaultMessageType == 'editMessageText';
        ret = user.id(1).storage.save('bot_configuration', 'checkNotPaidServices' => checkNotPaidServices, 'messageType' => 'sendMessage', 'menuCmd' => 'start' );
    END;
}}
{
    "answerCallbackQuery": {
         "callback_query_id": {{ callback_query.id }},
         "parse_mode":"HTML",
         "text": "✅ Тип сообщений изменен!",
        "show_alert": true
     }
},
{
    "shmRedirectCallback": {
        "callback_data": "admin:settings"
    }
}
{{ END }}


<% CASE 'admin:users:list' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin'; }}
{{
    limit = 7;
    offset = (args.0 || 0);
    users = ref(user.list_for_api('admin', 1, 'limit', limit, 'offset', offset, 'filter',{"gid" = 0}));
    getCountUsers = ref(user.list_for_api('admin', 1, filter, {"gid" = 0})).size;
}}
{{ TEXT = BLOCK }}
👨‍💻 Пользователи

👤 Всего пользователей: {{ getCountUsers - 1 }}
{{ END }}
{
    "sendMessage": {
        "text": "{{ TEXT.replace('\n','\n') }}",
        "reply_markup": {
            "inline_keyboard": [
                {{ FOR item IN users }}
                    {{ status = (item.block == 0 ? "🟢" : "🔴") }}
                    [
                        {
                            "text": "{{ status _' '_ item.full_name.replace('"', '\"')  }} ({{ item.user_id _'-'_ item.login }})",
                            "callback_data": "admin:users:id {{ item.user_id _' '_ offset }}"
                        }
                    ],
                {{ END }}
                {{ IF users.size == limit || offset > 0 }}
                    [
                        {{ IF offset > 0 }}
                            {
                                "text": "⬅️ Назад",
                                "callback_data": "admin:users:list {{ offset - limit }}"
                            },
                        {{ END }}
                        {{ IF users.size == limit }}
                            {
                                "text": "Ещё ➡️",
                                "callback_data": "admin:users:list {{ limit + offset }}"
                            }
                        {{ END }}
                    ],
                {{ END }}
                [
                    {
                        "text": "👨‍💻 Меню {{ menuRole = (user.settings.role == 'admin' ? 'администратора' : 'модератора'); menuRole; }}",
                        "callback_data": "admin:menu"
                    },
                    {
                        "text": "🏠 Главное меню",
                        "callback_data": "/menu"
                    }
                ]
            ]
        }
    }
}
{{ END }}

<% CASE 'admin:users:id' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin'; }}
{{
    userData = user.id(args.0);
    userPartner = user.id(userData.partner_id);
    userServices = ref(userData.services.list_for_api('category', '%'));
    offset = args.1;
}}

{{ TEXT = BLOCK }}
👤 <b>Информация о пользователе</b>

Статус: {{ userStatus = (userData.block == 0 ? "🟢 Активен" : "🔴 Заблокирован"); userStatus; }}

Имя: {{ userData.full_name.replace('"', '\"') }}
ID: {{ userData.user_id }}
Telegram: {{ userData.settings.telegram.login }}
Логин: {{ userData.login }}

Дата регистрации: {{ userData.created }}
Дата последнего входа: {{ userData.last_login }}
Кто пригласил: {{ userPartner ? userPartner.full_name + " - " + userPartner.login : "❌ Нет данных" }}

Баланс: {{ userData.balance }} руб.  
Бонусы: {{ userData.get_bonus }} руб.  
Скидка: {{ userData.discount }}

Кол-во подписок: {{ userServices.size }}

{{ END }}

{
    "sendMessage": {
        "parse_mode": "HTML",
        "text": "{{ TEXT.replace('\n','\n') }}",
        "reply_markup": {
            "inline_keyboard": [
                [
                    {
                        "text": "🔐 Управление подписками",
                        "callback_data": "admin:users:id:subs {{ userData.user_id _' '_ offset }}"
                    }
                ],
                [
                    {
                        "text": "💸 Управление платежами",
                        "callback_data": "admin:users:id:pays {{ userData.user_id }}"
                    }
                ],
                [
                    {
                        "text": "🎁 Управление бонусами",
                        "callback_data": "admin:users:id:bonuses {{ userData.user_id }}"
                    }
                ],
				[
                    {
                        "text": "🎁 Управление бонусами",
                        "callback_data": "admin:users:id:bonuses {{ userData.user_id }}"
                    }
                ],
				[
                    {
                        "text": "✉️ Написать пользователю 💬",
                        "callback_data": "admin:user:msg {{ user.settings.telegram.chat_id }}"
                    }
                ],
                [
                    {
                        "text": "{{ status = (userData.block == 0 ? "🔴 Заблокировать" : "🟢 Активировать"); status; }}",
                        "callback_data": "admin:users:block {{ userData.user_id }}"
                    }
                ],
                [
                    {
                        "text": "⬅️ Назад",
                        "callback_data": "admin:users:list {{ args.1 }}"
                    }
                ],
                [
                    {
                        "text": "👨‍💻 Меню {{ menuRole = (user.settings.role == 'admin' ? 'администратора' : 'модератора'); menuRole; }}",
                        "callback_data": "admin_menu"
                    },
                    {
                        "text": "🏠 Главное меню",
                        "callback_data": "/menu"
                    }
                ]
            ]
        }
    }
}
{{ END }}

<% CASE 'admin:user:msg' %>
{
"sendMessage": {
        "text": "#{{ args.0 }}#\nВведите сообщение для пользователя",
        "reply_markup": {
            "force_reply": true
        }
    }
}

<% CASE 'admin:users:block' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin' }}
{{
    # Arguments 
    #   0. - id of user

    # Variables
        userData = user.id(args.0);
}}
{{ retcode = (userData.block == 1 ? "0" : "1"); }}
{{ ret = userData.set(block = retcode) }}
{
    "answerCallbackQuery": {
         "callback_query_id": {{ callback_query.id }},
         "parse_mode":"HTML",
         "text": "✅ Пользователь {{ userData.full_name.replace('"', '\"')  }} ({{ userData.user_id }}) {{ status = (userData.block == 1 ? "🔴 заблокирован" : "🟢 активирован"); status; }}",
         "show_alert": true
     }
},
{
    "shmRedirectCallback": {
        "callback_data": "admin:users:id {{ userData.user_id }}"
    }
}
{{ END }}

<% CASE 'admin:users:id:subs' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin' }}
{{
    limit = 7;
    last_offset = (args.1 || 0);
    offset = (args.2 || 0);
    userData = user.id(args.0);
    userServices = ref(userData.services.list_for_api('limit', limit, 'offset', offset));
}}
{{ TEXT = BLOCK }}
🔐 Управление подписками

Имя: {{ userData.full_name.replace('"', '\"')  }}
ID: {{ userData.user_id }}
Telegram: {{ userData.settings.telegram.login }}
Логин: {{ userData.login }}

{{ IF userServices.size <= 0}}
<b>У пользователя нет подписок!</b>
{{ END }}
{{ END }}
{
    "editMessageText": {
        "message_id": {{ message.message_id }},
        "parse_mode": "HTML",
        "text": "{{ TEXT.replace('\n','\n') }}",
        "reply_markup": {
            "inline_keyboard": [
                {{ FOR item in userServices }}
                    {{ status = (item.status == 'ACTIVE' ? "🟢" : "🔴") }}
                    [
                        {
                            "text": "{{ status; item.user_service_id _' - '_ item.name  }}",
                            "callback_data": "admin:subs:id {{ item.user_service_id _ ' ' _ item.user_id }}"
                        }
                    ],
                {{ END }}

                {{ IF userServices.size == limit }}
                    [
                        {
                            "text": "Ещё ➡️",
                            "callback_data": "admin:users:list {{ limit + offset }}"
                        }
                    ],
                {{ END }}

                {{ IF offset > 0 }}
                    [
                        {
                            "text": "⬅️ Назад",
                            "callback_data": "admin:users:list {{ offset - limit }}"
                        }
                    ],
                {{ END }}

                [
                    {
                        "text": "➕ Добавить услугу",
                        "callback_data": "admin:subs:add {{ userData.user_id }}"
                    }
                ],
                [
                    {
                        "text": "➕ Добавить услугу (бесплатно)",
                        "callback_data": "admin:subs:add:free {{ userData.user_id }}"
                    }
                ],
                [
                    {
                        "text": "⬅️ Информация о пользователе",
                        "callback_data": "admin:users:id {{ userData.user_id _' '_ last_offset }}"
                    }
                ],
                [
                    {
                        "text": "👨‍💻 Меню {{ menuRole = (user.settings.role == 'admin' ? 'администратора' : 'модератора'); menuRole }}",
                        "callback_data": "admin:menu"
                    }
                ]
            ]
        }
    }
}
{{ END }}

<% CASE ['admin:users:id:subs'] %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin' }}
{{
    limit = 7;
    last_offset = (args.1 || 0);
    offset = (args.2 || 0);
    userData = user.id(args.0);
    userServices = ref(userData.services.list_for_api('limit', limit, 'offset', offset));
}}

{{ TEXT = BLOCK }}
🔐 <b>Управление подписками</b>

👤 Имя: {{ userData.full_name.replace('"', '\"')  }}
🆔 ID: {{ userData.user_id }}  
📱 Telegram: {{ userData.settings.telegram.login }}
🔑 Логин: {{ userData.login }}  

{{ IF userServices.size <= 0 }}
<b>У пользователя нет подписок!</b>
{{ END }}
{{ END }}

{
    "editMessageText": {
        "message_id": {{ message.message_id }},
        "parse_mode": "HTML",
        "text": "{{ TEXT.replace('\n','\n') }}",
        "reply_markup": {
            "inline_keyboard": [
                {{ FOR item in userServices }}
                {{ status = (item.status == 'ACTIVE' ? "🟢" : "🔴") }}
                [
                    {
                        "text": "{{ status }} {{ item.user_service_id }} - {{ item.name }}",
                        "callback_data": "admin:subs:id {{ item.user_service_id _ ' ' _ item.user_id }}"
                    }
                ],
                {{ END }}

                {{ IF userServices.size == limit }}
                [
                    {
                        "text": "➡️ Ещё",
                        "callback_data": "admin:users:list {{ limit + offset }}"
                    }
                ],
                {{ END }}

                {{ IF offset > 0 }}
                [
                    {
                        "text": "⬅️ Назад",
                        "callback_data": "admin:users:list {{ offset - limit }}"
                    }
                ],
                {{ END }}

                [
                    {
                        "text": "➕ Добавить услугу",
                        "callback_data": "admin:subs:add {{ userData.user_id }}"
                    }
                ],
                [
                    {
                        "text": "➕ Добавить услугу (бесплатно)",
                        "callback_data": "admin:subs:add:free {{ userData.user_id }}"
                    }
                ],
                [
                    {
                        "text": "⬅️ Информация о пользователе",
                        "callback_data": "admin:users:id {{ userData.user_id _' '_ last_offset }}"
                    }
                ],
                [
                    {
                        "text": "👨‍💻 Меню {{ menuRole = (user.settings.role == 'admin' ? 'администратора' : 'модератора'); menuRole; }}",
                        "callback_data": "admin:menu"
                    }
                ]
            ]
        }
    }
}
{{ END }}

<% CASE 'admin:subs:add' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin' }}
{{
    # Переменные
    userData = user.id(args.0);
    servicesArray = ref(service.list_for_api).nsort('service_id');
    last_offset = args.1 || 0;
}}

{{ TEXT = BLOCK }}
➕ <b>Выберите услугу для пользователя</b>  
👤 Имя: {{ userData.full_name.replace('"', '\"') }}  
🆔 ID: {{ userData.user_id }}

{{ IF servicesArray.size == 0 }}
⚠️ <b>Нет доступных услуг для добавления.</b>
{{ END }}
{{ END }}

{
    "editMessageText": {
        "message_id": {{ message.message_id }},
        "parse_mode": "HTML",
        "text": "{{ TEXT.replace('\n','\n') }}",
        "reply_markup": {
            "inline_keyboard": [
                {{ FOR item in servicesArray }}
                [
                    {
                        "text": "{{ item.name _' '_ item.descr }} - {{ item.cost }} ₽",
                        "callback_data": "admin:subs:add:confirm {{ userData.user_id _' '_ item.service_id }}"
                    }
                ],
                {{ END }}

                [
                    {
                        "text": "⬅️ Назад",
                        "callback_data": "admin:users:id:subs {{ userData.user_id _' '_ args.1 }}"
                    }
                ],
                [
                    {
                        "text": "⬅️ Информация о пользователе",
                        "callback_data": "admin:users:id {{ userData.user_id _' '_ last_offset }}"
                    }
                ]
            ]
        }
    }
}
{{ END }}

<% CASE 'admin:subs:add:free' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin' }}
{{
    # Variables
    userData = user.id(args.0);
    servicesArray = ref(service.list_for_api).nsort('service_id');
}}
{{ TEXT = BLOCK }}
➕ Выберите услугу с 0 стоимостью для создания пользователю {{ userData.full_name.replace('"', '\"')  }} ({{ userData.user_id }})
{{ END }}

{
    "editMessageText": {
        "message_id": {{ message.message_id }},
        "parse_mode": "HTML",
        "text": "{{ TEXT.replace('\n','\n') }}",
        "reply_markup": {
            "inline_keyboard": [
    {{ FOR item in servicesArray }}
        [
            {
                "text": "{{ item.name _' '_ item.descr }} - {{ item.cost }} ₽",
                "callback_data": "admin:subs:add:confirm {{ userData.user_id _' '_ item.service_id _' free' }}"
            }
        ],
    {{ END }}
    [
        {
            "text": "⬅️ Назад",
            "callback_data": "admin:users:id:subs {{ userData.user_id _' '_ args.1 }}"
        }
    ],
    [
        {
            "text": "⬅️ Информация о пользователе",
            "callback_data": "admin:users:id {{ userData.user_id _' '_ last_offset }}"
        }
    ]
            ]
        }
    }
}
{{ END }}

<% CASE '/admusermsg' %>
{
"sendMessage": {
        "text": "#{{ args.0 }}#\nВведите сообщение для пользователя",
        "reply_markup": {
            "force_reply": true
        }
    }
}

<% CASE 'admin:subs:id' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin' }}
{{
    # Arguments:
        # 0 - ID of user service id 
        # 1 - ID of user
    # Variables:
    USE date;
    userData = user.id(args.1);
    userService = userData.us.id(args.0);
    userServiceData = service.id(userService.service_id);
    userServiceNext = service.id(userService.next);
    userSubUrl = (userData.storage.read('name', 'vpn_mrzb_'_ userService.user_service_id).subscription_url || "https://notfound.com");
    subData = http.get(userSubUrl _'/info');
}}
{{ TEXT = BLOCK }}
🔐 Подписка {{ userServiceData.name }} пользователя {{ userData.full_name.replace('"', '\"') }} ({{ userData.user_id }})

ID: {{ userService.user_service_id }}
ID списания: {{ userService.withdraw_id }}
Статус: {{ userService.status }}
Создана: {{ userService.created }}
Заканчивается: {{ userService.expire }}
Следующий тариф: {{ userServiceNext.name }}

Последний онлайн: {{ subData.online_at ? date.format(subData.online_at, '%d.%m.%Y %R') : 'нет информации' }}

{{ END }}

{
    "editMessageText": {
        "message_id": {{ message.message_id }},
        "parse_mode": "HTML",
        "text": "{{ TEXT.replace('\n','\n') }}",
        "reply_markup": {
            "inline_keyboard": [
                [
                    {
                        "text": "🔗 Подписка {{ userService.user_service_id }} - {{ userServiceData.name }}",
                        "web_app": {
                            "url": "{{ userSubUrl }}"
                        }
                    }
                ],
                {{ IF userService.status == 'ACTIVE' || userService.status == 'BLOCK' }}
                    [
                        {
                            "text": "{{ status = (userService.status == 'ACTIVE' ? "🔴 Заблокировать" : "🟢 Активировать"); status; }}",
                            "callback_data": "admin:subs:change:status {{ userService.user_service_id }}"
                        }
                    ],
                {{ ELSIF userService.status == 'PROGRESS' }}
                    [
                        {
                            "text": "⏳ Ожидание (обновите)",
                            "callback_data": "admin:subs:id {{ userService.user_service_id }}"
                        }
                    ],
                {{ END }}
                {{ IF userService.status == 'BLOCK' || userService.status == 'NOT PAID' }}
                    [
                        {
                            "text": "❌ Удалить подписку",
                            "callback_data": "admin:subs:delete {{ userService.user_service_id }}"
                        }
                    ],
                {{ END }}
                [
                    {
                        "text": "🫰 Информация о списании",
                        "callback_data": "admin:withdraws:id {{ userService.withdraw_id }}"
                    }
                ],
                [
                    {
                        "text": "⎘ Сменить текущ. тариф",
                        "callback_data": "admin:subs:change:current {{ userService.user_service_id }}"
                    }
                ],
                [
                    {
                        "text": "⎘ Сменить след. тариф",
                        "callback_data": "admin:subs:change:next {{ userService.user_service_id }}"
                    }
                ],
                [
                    {
                        "text": "⬅️ Назад",
                        "callback_data": "admin:users:id:subs {{ userData.user_id }}"
                    }
                ],
                [
                    {
                        "text": "👨‍💻 Меню {{ menuRole = (user.settings.role == 'admin' ? 'администратора' : 'модератора'); menuRole; }}",
                        "callback_data": "admin:menu"
                    },
                    {
                        "text": "🏠 Главное меню",
                        "callback_data": "/menu"
                    }
                ]
            ]
        }
    }
}
{{ END }}

<% CASE 'admin:subs:change:current' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin'; }}
{{
    userService = ref(us.list_for_api('admin', 1, 'filter', {"user_service_id" = args.0})).first;
    userData = user.id(userService.user_id);
    userServiceData = service.id(userService.service_id);
}}
{{ TEXT = BLOCK }}
⎘ Выберите тариф на изменение для подписки {{ userServiceData.name }} пользователя {{ userData.full_name.replace('"', '\"')  }} ({{ userData.user_id }})

{{ END }}

{
    "editMessageText": {
        "message_id": {{ message.message_id }},
        "parse_mode": "HTML",
        "text": "{{ TEXT.replace('\n','\n') }}",
        "reply_markup": {
            "inline_keyboard": [
                {{ FOR list IN ref(service.api_price_list).nsort('service_id') }}
                    [
                        {
                            "text": "{{ list.name _' '_ list.descr }} - {{ list.cost }} ₽",
                            "callback_data": "admin:subs:change:current:confirm {{ userService.user_service_id _ ' ' _ list.service_id }}"
                        }
                    ],
                {{ END }}
                [
                    {
                        "text": "⬅️ Назад",
                        "callback_data": "admin:subs:id {{ userService.user_service_id }}"
                    }
                ],
                [
                    {
                        "text": "👨‍💻 Меню {{ menuRole = (user.settings.role == 'admin' ? 'администратора' : 'модератора'); menuRole; }}",
                        "callback_data": "admin:menu"
                    },
                    {
                        "text": "🏠 Главное меню",
                        "callback_data": "/menu"
                    }
                ]
            ]
        }
    }
}
{{ END }}

<% CASE 'admin:subs:change:current:confirm' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin'; }}
{{
    nextService = args.1;
    data = ref(us.list_for_api('admin', 1, 'filter', {"user_service_id" = args.0})).first;
    userData = user.id(data.user_id);
    serviceData = service.id(data.service_id);
    userServiceNext = service.id(nextService);
}}
{{ TEXT = BLOCK }}
✅ Тариф для подписки {{ serviceData.name }} ({{ data.user_service_id }}) пользователя {{ userData.full_name.replace('"', '\"')  }} ({{ userData.user_id }}) изменён на {{ userServiceNext.name }}
{{ END }}
{
    "answerCallbackQuery": {
         "callback_query_id": {{ callback_query.id }},
         "parse_mode":"HTML",
         "text": "{{ TEXT.replace('\n','\n') }}",
         "show_alert": true
     }
},
{
    "shmRedirectCallback": {
        "callback_data": "admin:subs:id {{ data.user_service_id }}"
    }
}
{{ ret = userData.us.id(data.user_service_id).change('service_id' = nextService) }}


<% CASE 'admin:subs:change:next' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin'; }}
{{
    userService = ref(us.list_for_api('admin', 1, 'filter', {"user_service_id" = args.0})).first;
    userData = user.id(userService.user_id);
    userServiceData = service.id(userService.service_id);
    userServiceNext = service.id(userService.next);
}}
{{ TEXT = BLOCK }}
⎘ Выберите следующий тариф для подписки {{ userServiceData.name }} пользователя {{ userData.full_name.replace('"', '\"')  }} ({{ userData.user_id }})

{{ IF userService.next != userService.service_id || userService.next != 0 }}
Следующий тариф: {{ userServiceNext.name }} ({{ userService.next }})
{{ END }}
{{ END }}

{
    "editMessageText": {
        "message_id": {{ message.message_id }},
        "parse_mode": "HTML",
        "text": "{{ TEXT.replace('\n','\n') }}",
        "reply_markup": {
            "inline_keyboard": [
                {{ FOR list IN ref(service.api_price_list).nsort('service_id') }}
                    [
                        {
                            "text": "{{ list.name _' '_ list.descr }} - {{ list.cost }} ₽",
                            "callback_data": "admin:subs:change:next:confirm {{ userService.user_service_id _ ' ' _ list.service_id }}"
                        }
                    ],
                {{ END }}
                [
                    {
                        "text": "⬅️ Назад",
                        "callback_data": "admin:subs:id {{ userService.user_service_id }}"
                    }
                ],
                [
                    {
                        "text": "👨‍💻 Меню {{ menuRole = (user.settings.role == 'admin' ? 'администратора' : 'модератора'); menuRole; }}",
                        "callback_data": "admin:menu"
                    },
                    {
                        "text": "🏠 Главное меню",
                        "callback_data": "/menu"
                    }
                ]
            ]
        }
    }
}
{{ END }}

<% CASE 'admin:subs:change:next:confirm' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin'; }}
{{
    nextService = args.1;
    data = ref(us.list_for_api('admin', 1, 'filter', {"user_service_id" = args.0})).first;
    userData = user.id(data.user_id);
    serviceData = service.id(data.service_id);
    userServiceNext = service.id(nextService);
}}
{{ ret = userData.us.id(data.user_service_id).set("next", nextService) }}
{{ TEXT = BLOCK }}
✅ Следующий тариф для подписки {{ serviceData.name }} ({{ data.user_service_id }}) пользователя {{ userData.full_name.replace('"', '\"') }} ({{ userData.user_id }}) изменён на {{ userServiceNext.name }}
{{ END }}
{
    "answerCallbackQuery": {
         "callback_query_id": {{ callback_query.id }},
         "parse_mode":"HTML",
         "text": "{{ TEXT.replace('\n','\n') }}",
         "show_alert": true
     }
},
{
    "shmRedirectCallback": {
        "callback_data": "admin:subs:id {{ data.user_service_id }}"
    }
}
{{ END }}

<% CASE 'admin:subs:change:status' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin'; }}
{{
    data = ref(us.list_for_api('admin', 1, 'filter', {"user_service_id" = args.0})).first;
    userData = user.id(data.user_id);
    serviceData = service.id(data.service_id);
}}
{{ IF data.status == 'ACTIVE' }}
    {{ ret = userData.us.id(data.user_service_id).block }}
{{ ELSIF data.status == 'BLOCK' }}
    {{ ret = userData.us.id(data.user_service_id).activate }}
{{ END }}
{
    "answerCallbackQuery": {
         "callback_query_id": {{ callback_query.id }},
         "parse_mode":"HTML",
         "text": "✅ Услуга {{ serviceData.name }} ({{ data.user_service_id }}) пользователя {{ userData.full_name.replace('"', '\"')  }} ({{ userData.user_id }}) {{ status = (data.status == 'ACTIVE' ? "🔴 заблокирована" : "🟢 активирована"); status; }}",
        "show_alert": true
     }
},
{
    "shmRedirectCallback": {
        "callback_data": "admin:subs:id {{ data.user_service_id }}"
    }
}
{{ END }}

<% CASE 'admin:subs:delete' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin'; }}
{{
    data = ref(us.list_for_api('admin', 1, 'filter', {"user_service_id" = args.0})).first;
    userData = user.id(data.user_id);
    serviceData = service.id(data.service_id);
}}
{{ IF data.status == 'BLOCK' || data.status == 'NOT PAID' }}
    {{ ret = userData.us.id(data.user_service_id).delete }}
{{ END }}
{
    "answerCallbackQuery": {
         "callback_query_id": {{ callback_query.id }},
         "parse_mode":"HTML",
         "text": "❌ Услуга {{ serviceData.name }} ({{ data.user_service_id }}) пользователя {{ userData.full_name.replace('"', '\"')  }} ({{ userData.user_id }}) удалена!",
        "show_alert": true
     }
},
{
    "shmRedirectCallback": {
        "callback_data": "admin:users:id:subs {{ userData.user_id }}"
    }
}
{{ END }}

<% CASE 'admin:users:id:pays' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin'; }}
{{
    limit = 5;
    offset = args.1 || 0;
    userData = user.id(args.0);
    userPays = ref(userData.pays.list_for_api('limit', limit, 'offset', offset ));
}}
{{ TEXT = BLOCK }}
👨‍💻 Управление платежами пользователя {{ userData.full_name.replace('"', '\"') }} ({{ userData.user_id }})

{{ END }}
{
    "editMessageText": {
        "message_id": {{ message.message_id }},
        "parse_mode": "HTML",
        "text": "{{ TEXT.replace('\n','\n') }}",
        "reply_markup": {
            "inline_keyboard": [
                {{ FOR item in userPays }}
                    [
                        {
                            "text": "(ID: {{ item.id }}), {{ item.money }} руб, {{ item.date }}",
                            "callback_data": "admin:pays:id {{ item.id }}"
                        }
                    ],
                {{ END }}
                {{ IF offset > 0 }}
                    [
                        {
                            "text": "⬅️ Назад",
                            "callback_data": "admin:users:id:pays {{ userData.user_id _' ' }} {{ offset - limit }}"
                        }
                    ],
                {{ END }}
                {{ IF userPays.size == limit }}
                    [
                        {
                            "text": "Ещё ➡️",
                            "callback_data": "admin:users:id:pays {{ userData.user_id _' ' }} {{ limit + offset }}"
                        }
                    ],
                {{ END }}
                [
                    {
                        "text": "➕ Добавить платеж",
                        "callback_data": "admin:pays:add {{ userData.user_id }}"
                    }
                ],
                [
                    {
                        "text": "⬅️ Информация о пользователе",
                        "callback_data": "admin:users:id {{ userData.user_id }}"
                    }
                ],
                [
                    {
                        "text": "👨‍💻👨‍💻 Меню {{ menuRole = (user.settings.role == 'admin' ? 'администратора' : 'модератора'); menuRole; }}",
                        "callback_data": "admin:menu"
                    },
                    {
                        "text": "🏠 Главное меню",
                        "callback_data": "/menu"
                    }
                ]
            ]
        }
    }
}
{{ END }}

<% CASE 'admin:pays:id' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin'; }}
{{
    userPay = ref(pay.list_for_api('admin', 1, 'filter', {"id" = args.0})).first;
    payData = userPay.comment.object;
    payMethod = payData.payment_method;
    payCard = payMethod.card;
    userData = user.id(userPay.user_id);
	partnerData = user.id(data.comment.from_user_id);
}}
{{ TEXT = BLOCK }}
💸 Информация о платеже ID {{ userPay.id }} пользователя {{ userData.full_name.replace('"', '\"')  }} ({{ userData.user_id }})

Дата платежа: {{ userPay.date }}
Платежная система: {{ userPay.pay_system_id }}
Сумма: {{ userPay.money }} руб.

{{ IF data.comment.from_user_id }}
<blockquote>{{ data.comment.percent }}% от {{ userData.full_name.replace('"', '\"')  }} ({{ partnerData.user_id }})</blockquote>
{{ END }}

{{ IF data.comment.msg }}
<blockquote>{{ data.comment.msg }}</blockquote>
{{ END }}

{{ IF userPay.comment.comment }}
<b>Комментарий к платежу</b>
<blockquote>{{ userPay.comment.comment }}</blockquote>
{{ END }}

{{ IF payData }}
<b>Данные о платеже</b>
<blockquote>
ID в системе: {{ payData.id }}
Статус: {{ payData.status }}
{{ IF payCard }}
Тип карты: {{ payCard.card_type }}
Номер карты: {{ payCard.first6 }}******{{ payCard.last4 }}
Банк: {{ payCard.issuer_name }}
Страна банка: {{ payCard.issuer_country }}
Срок действия: {{ payCard.expiry_month }}/{{ payCard.expiry_year }}
{{ END }}
{{ IF payMethod.type == 'sbp' }}
Тип оплаты: СБП
Номер операции в СБП: {{ payMethod.sbp_operation_id }}
Бик Банка: {{ payMethod.payer_bank_details.bic }}
{{ END }}

{{ IF payMethod.title.match('YooMoney') }}
Кошелек YooMoney: {{ payMethod.title }}
ID кошелька: {{ payMethod.account_number }}
{{ END }}
</blockquote>
{{ END }}

{{ END }}

{
    "editMessageText": {
        "message_id": {{ message.message_id }},
        "parse_mode": "HTML",
        "text": "{{ TEXT.replace('\n','\n') }}",
        "reply_markup": {
            "inline_keyboard": [
    [
        {
            "text": "⬅️ Назад",
            "callback_data": "admin:users:id:pays {{ userPay.user_id }}"
        }
    ],
    [
        {
            "text": "👨‍💻 Меню {{ menuRole = (user.settings.role == 'admin' ? 'администратора' : 'модератора'); menuRole; }}",
            "callback_data": "admin:menu"
        },
        {
            "text": "🏠 Главное меню",
            "callback_data": "/menu"
        }
    ]
            ]
        }
    }
}
{{ END }}

<% CASE 'admin:pays:add' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin'; }}
{{
    userData = user.id(args.0);
}}
{{ TEXT = BLOCK }}
💸 Выберите сумму, которую хотите начислить пользователю {{ userData.full_name.replace('"', '\"')  }} ({{ userData.user_id }})
Текущий баланс: {{ userData.balance }} руб.

{{ END }}
{
    "editMessageText": {
        "message_id": {{ message.message_id }},
        "parse_mode": "HTML",
        "text": "{{ TEXT.replace('\n','\n') }}",
        "reply_markup": {
            "inline_keyboard": [
                [
                    {
                        "text": "10 руб",
                        "callback_data": "admin:pays:add:confirm {{ userData.user_id }} 10"
                    },
                    {
                        "text": "20 руб",
                        "callback_data": "admin:pays:add:confirm {{ userData.user_id }} 20"
                    }
                ],
                [
                    {
                        "text": "50 руб",
                        "callback_data": "admin:pays:add:confirm {{ userData.user_id }} 50"
                    },
                    {
                        "text": "100 руб",
                        "callback_data": "admin:pays:add:confirm {{ userData.user_id }} 100"
                    }
                ],
                [
                    {{ FOR item IN ref(service.api_price_list('category', '%')).nsort('cost') }}
                        {
                            "text": "{{ item.name }} - {{ item.cost }}₽",
                            "callback_data": "admin:pays:add:confirm {{ userData.user_id _ ' ' }} {{ item.cost }}"
                        },
                    {{ END }}
                ],
                [
                    {
                        "text": "Ввести свою сумму",
                        "callback_data": "admin:pays:add:manual {{ userData.user_id }}"
                    }
                ],
                [
                    {
                        "text": "⬅️ Назад",
                        "callback_data": "admin:users:id:pays {{ userData.user_id }}"
                    }
                ],
                [
                    {
                        "text": "👨‍💻 Меню {{ menuRole = (user.settings.role == 'admin' ? 'администратора' : 'модератора'); menuRole; }}",
                        "callback_data": "admin:menu"
                    },
                    {
                        "text": "🏠 Главное меню",
                        "callback_data": "/menu"
                    }
                ]
            ]
        }
    }
}
{{ END }}

<% CASE 'admin:pays:add:manual' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin'; }}
{{
    userData = user.id(args.0);

    ret = user.set_settings({'state' => 'awaiting_amount'});
    ret = user.set_settings({'bot' => {'switchUser' => userData.user_id} });
}}

{{ TEXT = BLOCK }}
💬 Введите сумму для пополнения баланса пользователя {{ userData.full_name.replace('"', '\"') }}
{{ END }}



<% CASE 'admin:pays:add:confirm' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin'; }}
{{
    userData = user.id(args.0);
    amount = args.1;
    pay = userData.payment('money', amount, 'pay_system_id', 'Ручное начисление от администратора')
}}
{
    "answerCallbackQuery": {
         "callback_query_id": {{ callback_query.id }},
         "parse_mode":"HTML",
         "text": "Баланс пользователя {{ userData.full_name.replace('"', '\"')  }} ({{ userData.user_id }}) пополнен на {{ amount }} руб. Текущий баланс - {{ userData.balance }}",
         "show_alert": true
     }
},
{
    "shmRedirectCallback": {
        "callback_data": "admin:pays:add {{ userData.user_id }}"
    }
}
{{ END }}

<% CASE 'admin:users:id:bonuses' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin'; }}
{{
    limit = 5;
    offset = (args.1 || 0);
    userData = user.id(args.0);
    userBonuses = ref(bonus.list_for_api('admin', 1, 'limit', limit, 'offset', offset, 'filter', {"user_id" = userData.user_id}));
}}
{{ TEXT = BLOCK }}
👨‍💻 Управление бонусами пользователя {{ userData.full_name.replace('"', '\"')  }} ({{ userData.user_id }})

Баланс бонусов: {{ userData.get_bonus }} руб.
{{ END }}

{
    "editMessageText": {
        "message_id": {{ message.message_id }},
        "parse_mode": "HTML",
        "text": "{{ TEXT.replace('\n','\n') }}",
        "reply_markup": {
            "inline_keyboard": [
                {{ FOR item in userBonuses }}
                    [
                        {
                            "text": "ID: {{ item.id }} — {{ item.bonus }} руб.",
                            "callback_data": "admin:bonuses:id {{ item.id _ ' ' _ offset }}"
                        }
                    ],
                {{ END }}
                {{ IF offset > 0 }}
                    [
                        {
                            "text": "⬅️ Назад",
                            "callback_data": "admin:users:id:bonuses {{ userData.user_id _' ' }} {{ offset - limit }}"
                        }
                    ],
                {{ END }}
                {{ IF userBonuses.size == limit }}
                    [
                        {
                            "text": "Ещё ➡️",
                            "callback_data": "admin:users:id:bonuses {{ userData.user_id _' ' }} {{ limit + offset }}"
                        }
                    ],
                {{ END }}
                [
                    {
                        "text": "➕ Добавить бонусы",
                        "callback_data": "admin:bonuses:add {{ userData.user_id }}"
                    }
                ],
                [
                    {
                        "text": "⬅️ Информация о пользователе",
                        "callback_data": "admin:users:id {{ userData.user_id }}"
                    }
                ],
                [
                    {
                        "text": "👨‍💻 Меню {{ menuRole = (user.settings.role == 'admin' ? 'администратора' : 'модератора'); menuRole; }}",
                        "callback_data": "admin:menu"
                    },
                    {
                        "text": "🏠 Главное меню",
                        "callback_data": "/menu"
                    }
                ]
            ]
        }
    }
}
{{ END }}

<% CASE 'admin:bonuses:id' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin'; }}
{{
    offset = args.1;
    data = ref(bonus.list_for_api('admin', 1, 'limit', limit, 'offset', offset, 'filter', {"id" = args.0})).first;
    userData = user.id(data.user_id);
    partnerData = user.id(data.comment.from_user_id)
}}
{{ TEXT = BLOCK }}
💸 Информация о начислении бонусов ID {{ data.id }} пользователю {{ userData.full_name.replace('"', '\"')  }} ({{ userData.user_id }})

ID начисления: {{ data.id }}
Дата начисления: {{ data.date }}
Сумма начисления: {{ data.bonus }} руб.

{{ IF data.comment.from_user_id }}
<blockquote>{{ data.comment.percent }}% от {{ userData.full_name.replace('"', '\"')  }} ({{ partnerData.user_id }})</blockquote>
{{ END }}

{{ IF data.comment.msg }}
<blockquote>{{ data.comment.msg }}</blockquote>
{{ END }}
{{ END }}
{
    "editMessageText": {
        "message_id": {{ message.message_id }},
        "parse_mode": "HTML",
        "text": "{{ TEXT.replace('\n','\n') }}",
        "reply_markup": {
            "inline_keyboard": [
                [
                    {
                        "text": "⬅️ Назад",
                        "callback_data": "admin:users:id:bonuses {{ userData.user_id _ ' ' _ offset }}"
                    }
                ],
                [
                    {
                        "text": "👨‍💻 Меню {{ menuRole = (user.settings.role == 'admin' ? 'администратора' : 'модератора'); menuRole; }}",
                        "callback_data": "admin:menu"
                    },
                    {
                        "text": "🏠 Главное меню",
                        "callback_data": "/menu"
                    }
                ]
            ]
        }
    }
}
{{ END }}

<% CASE 'admin:bonuses:add' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin'; }}
{{
    userData = user.id(args.0);
}}
{{ TEXT = BLOCK }}
💸 Выберите кол-во бонусов, которые хотите начислить пользователю {{ userData.full_name.replace('"', '\"')  }} ({{ userData.user_id }})
Текущий баланс бонусов {{ userData.get_bonus }} руб.

{{ END }}
{
    "editMessageText": {
        "message_id": {{ message.message_id }},
        "parse_mode": "HTML",
        "text": "{{ TEXT.replace('\n','\n') }}",
        "reply_markup": {
            "inline_keyboard": [
                [
                    {
                        "text": "10 руб",
                        "callback_data": "admin:bonuses:add:confirm {{ userData.user_id }} 10"
                    },
                    {
                        "text": "20 руб",
                        "callback_data": "admin:bonuses:add:confirm {{ userData.user_id }} 20"
                    },
                    {
                        "text": "30 руб",
                        "callback_data": "admin:bonuses:add:confirm {{ userData.user_id }} 30"
                    },
                    {
                        "text": "40 руб",
                        "callback_data": "admin:bonuses:add:confirm {{ userData.user_id }} 40"
                    }
                ],
                [
                    {
                        "text": "50 руб",
                        "callback_data": "admin:bonuses:add:confirm {{ userData.user_id }} 50"
                    },
                    {
                        "text": "100 руб",
                        "callback_data": "admin:bonuses:add:confirm {{ userData.user_id }} 100"
                    },
                    {
                        "text": "150 руб",
                        "callback_data": "admin:bonuses:add:confirm {{ userData.user_id }} 150"
                    },
                    {
                        "text": "200 руб",
                        "callback_data": "admin:bonuses:add:confirm {{ userData.user_id }} 200"
                    }
                ],
                [
                    {
                        "text": "Убрать {{ userData.get_bonus }}",
                        "callback_data": "admin:bonuses:add:confirm {{ userData.user_id }} -{{ userData.get_bonus }}"
                    }
                ],
                [
                    {
                        "text": "⬅️ Назад",
                        "callback_data": "admin:users:id:bonuses {{ userData.user_id }}"
                    }
                ],
                [
                    {
                        "text": "👨‍💻 Меню {{ menuRole = (user.settings.role == 'admin' ? 'администратора' : 'модератора'); menuRole; }}",
                        "callback_data": "admin:menu"
                    },
                    {
                        "text": "🏠 Главное меню",
                        "callback_data": "/menu"
                    }
                ]
            ]
        }
    }
}
{{ END }}

<% CASE 'admin:bonuses:add:confirm' %>
{{
    userData = user.id(args.0);
    amount = args.1;
}}

{{ IF amount < 0 }}
    {{ ret = userData.set_bonus('bonus', amount, 'comment', {'msg' => 'Ручная корректировка от администратора'}); }}
{{ ELSE }}
    {{ ret = userData.set_bonus('bonus', amount, 'comment', {'msg' => 'Ручное начисление от администратора'}); }}
    {
        "sendMessage": {
            "chat_id": {{ userData.settings.telegram.chat_id }},
            "text": "🎁 Вам начислено {{ amount }} бонусов на счет от администратора",
            "parse_mode": "HTML",
            "reply_markup": {
                "inline_keyboard": [
                    [
                        {
                            "text": "👤 Личный кабинет",
                            "callback_data": "cabinet"
                        }
                    ]
                ]
            }
        }
    },
{{ END }}

{
    "answerCallbackQuery": {
         "callback_query_id": {{ callback_query.id }},
         "parse_mode":"HTML",
         "text": "Баланс бонусов пользователя {{ userData.full_name.replace('"', '\"')  }} ({{ userData.user_id }}) пополнен на {{ amount }} руб. Текущий баланс - {{ userData.get_bonus }}",
         "show_alert": true
     }
},
{
    "shmRedirectCallback": {
        "callback_data": "admin:bonuses:add {{ userData.user_id }}"
    }
}

<% CASE 'admin:withdraws:id' %>
{{
    data = ref(wd.list_for_api('admin', 1, 'filter', {"withdraw_id" = args.0})).first;
    userData = user.id(data.user_id);
}}
{{ TEXT = BLOCK }}
💸 Информация о списании №{{ data.withdraw_id }}

Пользователь: {{ userData.full_name.replace('"', '\"')  }} ({{ userData.user_id }})

Услуга: {{ data.name }} ({{ data.user_service_id }})
Стоимость: {{ data.cost }}
Дата создания: {{ data.create_date }}
Дата списания: {{ data.withdraw_date }}
Дата окончания по списанию: {{ data.end_date }}
Кол-во месяцев: {{ data.months }}

<b>Списание:</b>
<blockquote>
Скидка: {{ data.discount }}%
Бонусов: {{ data.bonus }} руб
<b>Всего: {{ data.total }}</b>

</blockquote>
{{ END }}

{
    "editMessageText": {
        "message_id": {{ message.message_id }},
        "parse_mode": "HTML",
        "text": "{{ TEXT.replace('\n','\n') }}",
        "reply_markup": {
            "inline_keyboard": [
    [
        {
            "text": "⬅️ Назад",
            "callback_data": "admin:subs:id {{ data.user_service_id _ ' ' _  userData.user_id }}"
        }
    ],
    [
        {
            "text": "👨‍💻 Меню {{ menuRole = (user.settings.role == 'admin' ? 'администратора' : 'модератора'); menuRole; }}",
            "callback_data": "admin:menu"
        },
        {
            "text": "🏠 Главное меню",
            "callback_data": "/menu"
        }
    ]
]
        }
    }
}

<% CASE '/admuserblock_toggle' %>
{{ IF user.settings.role == 'moderator' || user.settings.role == 'admin'; }}
{{
    # Arguments 
    #   0. - id of user

    # Variables
        userData = user.id(args.0);
}}
{{ retcode = (userData.block == 1 ? "0" : "1"); }}
{{ ret = userData.set(block = retcode) }}

{
    "answerCallbackQuery": {
        "callback_query_id": {{ callback_query.id }},
        "parse_mode": "HTML",
        "text": "✅ Пользователь {{ userData.full_name.replace('"', '\"')  }} ({{ userData.user_id }}) {{ status = (userData.block == 1 ? "🔴 заблокирован" : "🟢 активирован"); status; }}",
        "show_alert": true
    }
},
{
    "shmRedirectCallback": {
        "callback_data": "/admuser {{ userData.user_id }}"
    }
}
{{ END }}

<% CASE %>
{{ IF message.reply_to_message.chat.id == config.telegram_admin.id }}
{{ text = message.reply_to_message.caption || message.reply_to_message.text }}
{{ chatid = text.split('#').1 }}
{{ IF chatid }}
{{ IF message.photo }}
{
    "sendPhoto": {
        "protect_content": true,
        "parse_mode": "HTML",
        "chat_id": "{{ chatid }}",
        "photo": "{{ message.photo.0.file_id }}",
        "caption": "{{ message.text }}",
        "reply_markup" : {
            "inline_keyboard": [
                 [
                    {
                        "text": "🏠 Личный кабинет",
                        "callback_data": "/balance"
                    }
                ]
            ]
        }
    }
}
{{ ELSIF message.text }}
{
    "sendMessage": {
        "protect_content": true,
        "parse_mode": "HTML",
        "chat_id": "{{ chatid }}",
        "text": "{{ message.text }}",
        "reply_markup" : {
            "inline_keyboard": [
                 [
                    {
                        "text": "🏠 Личный кабинет",
                        "callback_data": "/balance"
                    }
                ]
            ]
        }
    }
}
{{ ELSIF message.document }}
{
    "sendDocument": {
        "protect_content": true,
        "parse_mode": "HTML",
        "chat_id": "{{ chatid }}",
        "document": "{{ message.document.file_id }}",
        "caption": "{{ message.text }}",
        "reply_markup" : {
            "inline_keyboard": [
                [
                    {
                        "text": "🏠 Личный кабинет",
                        "callback_data": "/balance"
                    }
                ]
            ]
        }
    }
}
{{ ELSIF message.video }}
{
    "sendVideo": {
        "protect_content": true,
        "parse_mode": "HTML",
        "chat_id": "{{ chatid }}",
        "video": "{{ message.video.file_id }}",
        "caption": "{{ message.caption }}",
        "reply_markup" : {
            "inline_keyboard": [
                 [
                    {
                        "text": "🏠 Личный кабинет",
                        "callback_data": "/balance"
                    }
                ]
            ]
        }
    }
}
{{ ELSIF message.text_with_links }}
{
    "sendMessage": {
        "protect_content": true,
        "parse_mode": "HTML",
        "chat_id": "{{ chatid }}",
        "text": "{{ message.text_with_links }}",
        "reply_markup" : {
            "inline_keyboard": [
                [
                    {
                        "text": "🏠 Личный кабинет",
                        "callback_data": "/balance"
                    }
                ]
            ]
        }
    }
}
{{ ELSE }}
{
    "sendMessage": {
        "chat_id": "{{ chatid }}",
        "text": "Доступны только текстовые сообщения, фото, файлы и видео"
    }
}
{{ END }}
{{ ELSE }}
{
    "sendMessage": {
        "chat_id": "{{ config.telegram_admin.id }}",
        "text": "Не удалось найти пользователя или вы не ответили на сообщение"
    }
}
{{ END }}
{{ ELSE }}
{{ IF message.photo }}
{
    "sendPhoto": {
        "protect_content": true,
        "parse_mode": "HTML",
        "chat_id": "{{ config.telegram_admin.id }}",
        "photo": "{{ message.photo.0.file_id }}",
        "caption": "#{{ user.settings.telegram.chat_id }}# \nСообщение от {{ user.full_name }} - {{ user.id }}:\n<a href=\"https://t.me/{{ user.settings.telegram.login }}\">{{ user.settings.telegram.login }}</a>\n\n{{ message.caption }}",
        "reply_markup" : {
            "inline_keyboard": [
                [
                    {
                        "text": "Профиль пользователя",
                        "callback_data": "admin:users:id {{ user.id }}"
                    }
                ],  [
                    {
                        "text": "Пользователи",
                        "callback_data": "admin:users:list"
                    },{
                        "text": "Админка",
                        "callback_data": "admin:menu"
                    }
                ],
                 [
                    {
                        "text": "🏠 Домой",
                        "callback_data": "/start"
                    }
                ]
            ]
        }
    }
}
{{ ELSIF message.text }}
{
    "sendMessage": {
        "protect_content": true,
        "parse_mode": "HTML",
        "chat_id": "{{ config.telegram_admin.id }}",
        "text": "#{{ user.settings.telegram.chat_id }}# \nСообщение от {{ user.full_name }} - {{ user.id }}:\n<a href=\"https://t.me/{{ user.settings.telegram.login }}\">{{ user.settings.telegram.login }}</a>\n\n{{ message.text }}",
              "reply_markup" : {
            "inline_keyboard": [
                [
                    {
                        "text": "Профиль пользователя",
                        "callback_data": "admin:users:id {{ user.id }}"
                    }
                ],  [
                    {
                        "text": "Пользователи",
                        "callback_data": "admin:users:list"
                    },{
                        "text": "Админка",
                        "callback_data": "admin:menu"
                    }
                ],
                 [
                    {
                        "text": "🏠 Домой",
                        "callback_data": "/start"
                    }
                ]
            ]
        }
    }
}
{{ ELSIF message.document }}
{
    "sendDocument": {
        "protect_content": true,
        "parse_mode": "HTML",
        "chat_id": "{{ config.telegram_admin.id }}",
        "document": "{{ message.document.file_id }}",
        "caption": "#{{ user.settings.telegram.chat_id }}# \nСообщение от {{ user.full_name }} - {{ user.id }}:\n<a href=\"https://t.me/{{ user.settings.telegram.login }}\">{{ user.settings.telegram.login }}</a>\n\n{{ message.caption }}",
            "reply_markup" : {
            "inline_keyboard": [
                [
                    {
                        "text": "Профиль пользователя",
                        "callback_data": "admin:users:id {{ user.id }}"
                    }
                ],  [
                    {
                        "text": "Пользователи",
                        "callback_data": "admin:users:list"
                    },{
                        "text": "Админка",
                        "callback_data": "admin:menu"
                    }
                ],
                 [
                    {
                        "text": "🏠 Домой",
                        "callback_data": "/start"
                    }
                ]
            ]
        }
    }
}
{{ ELSIF message.video }}
{
    "sendVideo": {
        "protect_content": true,
        "parse_mode": "HTML",
        "chat_id": "{{ config.telegram_admin.id }}",
        "video": "{{ message.video.file_id }}",
        "caption": ""#{{ user.settings.telegram.chat_id }}# \nСообщение от {{ user.full_name }} - {{ user.id }}:\n<a href=\"https://t.me/{{ user.settings.telegram.login }}\">{{ user.settings.telegram.login }}</a>\n\n{{ message.caption }}",
         "reply_markup" : {
            "inline_keyboard": [
                 [
                    {
                        "text": "Профиль пользователя",
                        "callback_data": "admin:users:id {{ user.id }}"
                    }
                ],  [
                    {
                        "text": "Пользователи",
                        "callback_data": "admin:users:list"
                    },{
                        "text": "Админка",
                        "callback_data": "admin:menu"
                    }
                ],
                 [
                    {
                        "text": "🏠 Домой",
                        "callback_data": "/start"
                    }
                ]
            ]
        }
    }
}
{{ ELSIF message.text_with_links }}
{
    "sendMessage": {
        "protect_content": true,
        "parse_mode": "HTML",
        "chat_id": "{{ config.telegram_admin.id }}",
        "text": ""#{{ user.settings.telegram.chat_id }}# \nСообщение от {{ user.full_name }} - {{ user.id }}:\n<a href=\"https://t.me/{{ user.settings.telegram.login }}\">{{ user.settings.telegram.login }}</a>\n\n{{ message.text_with_links }}",
             "reply_markup" : {
            "inline_keyboard": [
                 [
                    {
                        "text": "Профиль пользователя",
                        "callback_data": "admin:users:id {{ user.id }}"
                    }
                ],  [
                    {
                        "text": "Пользователи",
                        "callback_data": "admin:users:list"
                    },{
                        "text": "Админка",
                        "callback_data": "admin:menu"
                    }
                ],
                 [
                    {
                        "text": "🏠 Домой",
                        "callback_data": "/start"
                    }
                ]
            ]
        }
    }
}
{{ ELSE }}
{
    "sendMessage": {
        "text": "Доступны только текстовые сообщения, фото, файлы и видео"
    }
}
{{ END }}
{{ IF message.reply_to_message }}
{
    "forwardMessage": {
        "chat_id": "{{ config.telegram_admin.id }}",
        "from_chat_id": "{{ message.chat.id }}",
        "message_id": "{{ message.reply_to_message.message_id }}"
    }
}
{{ END }}
{{ END }}

<% END %>
