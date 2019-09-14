# Using FOSSProof on your website
FOSSProof offers multiple different services, which can be individually included on pages of your website.

## Initialise FOSSProof
To pull FOSSProof onto your webpage, make sure you copy `/resources/js/fossproof.min.js` to your website's code tree. For example's sake, we'll 
assume it's under `/static/js/fossproof.min.js`.

In your HTML, include fossproof with a script tag.

```html
<script src="/static/js/fossproof.min.js"></script>
```

Before using any of FOSSProof's features, you'll need an instance, which is initialised with the base URL of your FOSSProof server:

```js
var fp = new FossProof("ws://127.0.0.1:8080");
```

## Use the action notifications
This displays a popup notification to a user whenever somebody performs an action. This requires initialising a listener and then sending the actions.

For example, let's say you are promoting a newsletter.

When a user fills in the form and signs up for your newsletter, they will redirect to a thank you page.

You could set your homepage and form page as listeners, and have your thank you page perform the action.

### Listeners
On your listening pages (e.g. homepage and form page) initialise FossProof and call `initListen()`.

Javascript:

```js
var fp = new FossProof("ws://127.0.0.1:8080");
fp.initListen();
```

#### Customising the listener's popup
An object of variables can be passed to `initListen` to change various aspects of the popup message.

If you only want one type of popup, this config object can include just a `message` and `image` property.
Use the string `[name]` inside the message to be replaced by the action taker's name.

```js
{"message": "[name] has just subscribed!", "image": "/img/fossproof.png"}
```

To have multiple different popups for different actions, an object like this can be used instead:

```js
{
    "action_one": {
        "message": "[name] performed action one!",
        "image": "/img/fossproof/action_one.png",
    },
    "action_two": {
        "message": "[name] performed action two!",
        "image": "/img/fossproof/action.two.png",
    },
}
```

To set a global image for each action, set the `"image"` property on the outer object:
```js
{
    "image": "/img/global-img.png",
    "subscribe": {
        "message": "[name] subscribed!",
    }
}
```

In all cases, `"image"` is optional. If left out, no image will show. 


### Actions
**Note** Actions can also be posted server-side. See the server docs for instructions.

On your actions page (e.g. thank you page) initialise FossProof and call `sendAction` passing in the action type and the user's name.

Javascript:

```js
var fp = new FossProof("ws://127.0.0.1:8080");
fp.sendAction('subscribe', 'Bob');
```

## Use the live signup counter
To use the live signup counter, call the `initLiveSignupCount` method, passing the element `id` of the HTML element to replace with the count.

### Example

HTML:

```html
<div>
    We have had <span id="liveSignupCount">0</span> signups today!
</div>
```

Javascript:

```js
var fp = new FossProof("ws://127.0.0.1:8080");
fp.initLiveSignupCount("liveSignupCount");
```


