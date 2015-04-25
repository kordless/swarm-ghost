// # Ghost Configuration
// Setup your Ghost install for various environments
// Documentation can be found at http://support.ghost.org/config/

var path = require('path'),
    config;

config = {
    production: {
        url: 'http://%CNAME%',
        mail: {
            transport: 'SMTP',
            options: {
                service: 'Mailgun',
                auth: {
                    user: '%MAILGUN_USERNAME%', // mailgun username
                    pass: '%MAILGUN_APIKEY%'  // mailgun API key
                }
            }
        },
        database: {
            client: 'mysql',
            connection: {
                host     : '%MYSQL_SERVER%',
                user     : '%MYSQL_USERNAME%',
                password : '%MYSQL_PASSWORD%',
                database : '%MYSQL_DATABASE%',
                charset  : 'utf8'
            }
        },
        server: {
            host: '0.0.0.0',
            port: '2368'
        }
    }
};

// Export config
module.exports = config;
