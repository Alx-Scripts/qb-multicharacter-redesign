fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Kakarot'
description 'Allows players to create multiple characters'
version '1.2.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua'
}

-- loadscreen {
--     'load/html/index.html'
--   }
  
--   loadscreen_cursor 'yes'
--   loadscreen_manual_shutdown 'yes'

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@qb-apartments/config.lua',
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/reset.css',
    'html/vue.js',
    'html/swal2.js',
    'html/profanity.js',
    'html/particles.js',
    'html/app.js',
    'html/main.js',
    'html/img/**.png',
    'html/fonts/**.otf',
    'html/fonts/**.ttf',
    'html/pdf/**.pdf',
    'load/html/assets/**',
    'load/html/**',
}

dependencies {
    'qb-core',
    'qb-spawn'
}
