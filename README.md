A prototype to demonstrate saving editor state in the URL while also allowing saving to gist.

### Quick Start
```
spago build
npm run serve
```

Note that this also requires setting-up a github OAuth app with `gist` permissions, and another server for keeping a private `client_secret`.

See the [Authorizing OAuth Apps](https://developer.github.com/apps/building-oauth-apps/authorizing-oauth-apps/) page for info on this flow.

I'm using Azure Functions to host this backend. See the `azure` folder for more details.

