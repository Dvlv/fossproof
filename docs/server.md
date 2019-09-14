# Configuration
Configuring FOSSProof is done via the `fossproof-settings.json` file. The configurations are as follows:

- **domains**: Array of strings containing the url(s) which you intend to call FOSSProof from. FOSSProof will ignore any calls to its websockets from sources not in this list. For example, if your homepage is `"https://my-website.com/"`, you will need `"my-website.com"` in this array.

- **actions**: (optional) Array of strings representing the actions you will be sending to the API. Any action sent which is not in this array will not be used.
    - Default: ["subscribe"]


# Server Side Actions
To create an action from the server side, simply send a POST request containing the action name and user name to `<base_url>/api/action`.

TODO: Will this need to be JSON?

Python

```python
import requests

action_data = {
    "action": "subscribe",
    "name": "bob",
}
fp_url = "http://127.0.0.1:8080/api/action"

requests.post(fp_url, data=action_data)
```
