# Configuration
Configuring FOSSProof is done via the `fp-config.sdl` file. The configurations are as follows:

- **allow_sources**: Array of strings containing the url(s) which you intend to call FOSSProof from. FOSSProof will ignore any calls to its websockets 
from sources not in this list. For example, if your homepage is `"https://my-website.com/"`, you will need `"my-website.com"` in this array.


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
