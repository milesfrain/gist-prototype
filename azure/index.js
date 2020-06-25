const axios = require('axios');

const client_id = 'todo';
const client_secret = 'todo';

async function getToken(code) {
    const url = 'https://github.com/login/oauth/access_token'

    let body = { client_id, client_secret, code }

    try {
        const response = await axios.post(url, body);
        console.log(response.data);

        obj = {};
        for (const i of response.data.split('&')) {
            [k, v] = i.split('=');
            obj[k] = decodeURIComponent(v);
        }

        return obj;
    } catch (error) {
        console.log(error);
        return error;
    }
};

// Test with:
// curl -X POST http://localhost:7071/api/localtrigger -H "Content-Type: application/json" -d '{"code":"put-code-here"}'

module.exports = async function (context, req) {
    context.log(req)

    /* Azure does not accept POST with query params,
    so will never have anything in req.query.code.
    */
    if (req.body && req.body.code) {
        token = await getToken(req.body.code)
        context.res = {
            // status: 200, /* Defaults to 200 */
            body: token
        };
    }
    else {
        context.log("No code");
        context.res = {
            status: 400,
            body: "Code is missing"
        };
    }
};
