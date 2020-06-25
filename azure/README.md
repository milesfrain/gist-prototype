Using Azure Functions and [Core Tools](https://github.com/Azure/azure-functions-core-tools/blob/dev/README.md) for local development.


### Initial project setup:
There are compatibility issues outside of node.js version 10.

I'm using `nvm` to select this version.
```
nvm use 10
```

Install "Core Tools" from the above link, then run these commands to setup the project.
```
func init myapp --worker-runtime node --language javascript
cd myapp
npm install
func new --name HttpExample --template "HTTP trigger"
```

Then copy `index.js` to overwrite the file in the `localtrigger` directory.

In this file, define your new github OAuth app `client_id` and `client_secret`.

### Launching

Adjust your cors setting to match where your app is hosted for local development. This is the default port for `parcel`.
```
nvm use 10
func start --cors http://localhost:1234
```

### Testing

You can test locally via CLI with:
```
curl -X POST http://localhost:7071/api/localtrigger -H "Content-Type: application/json" -d '{"code":"put-code-here"}'
```
