class FossProof {
    constructor(baseUrl) {
        this.baseUrl = baseUrl;
        this.listenSocket = {};
        this.countSocket = {};
        this.actionSocket = {};

        this.popup = null;
        this.popupMessage = null;
        this.popupIsVisible = false;

        this.popupDisplayTime = 3500;
        this.popupCooldownTime = 3000;

        this.backlog = [];
    }

    initListen(config) {
        // create the popup html
        // listen on the websocket
        this.createPopupHtml(config);

        try {
            if (!('readystate' in this.listenSocket)) {
                this.listenSocket = new WebSocket(this.baseUrl + '/ws/listen-action');
            }

            this.listenSocket.onmessage = function(msg) {
                if (!this.popupIsVisible) {
                    this.parseAndDisplay(msg);
                } else {
                    this.backlog.push(msg);
                }
            }.bind(this);
        } catch (exception) {
            alert(exception);
        }

        setInterval(function() {
            this.displayBacklog()
        }.bind(this), 5000);
    }

    displayBacklog() {
        if (this.backlog.length) {
            if (!this.popupIsVisible) {
                this.parseAndDisplay(this.backlog.shift());
            }
        }
    }

    parseAndDisplay(msg) {
        var msgVal = JSON.parse(msg.data);
        var action = msgVal["action"];
        var name = msgVal["name"];

        this.displayPopup(action, name);
    }

    onPopupCooldown() {
        this.popupIsVisible = false;
    }

    displayPopup(action, name) {
        // TODO action stuff
        var message = "[name] just signed up!"
        // TODO if config overrides
        this.popupMessage.innerHTML = message.replace("[name]", name);
        this.popup.classList.add("visible");
        this.popupIsVisible = true;

        setTimeout(function() {
            this.hidePopup()
        }.bind(this), this.popupDisplayTime);
    }

    createPopupHtml(config) {
        var popupMain = document.createElement("div");
        popupMain.id = "fp-main";

        var popupImg = document.createElement("img");
        popupImg.src = config["image"] ? config["image"] : ""  // TODO default image
        popupImg.id = "fp-img"

        var popupMessage = document.createElement("span");
        popupMessage.id = "fp-message"

        popupMain.appendChild(popupImg);
        popupMain.appendChild(popupMessage);
        document.body.appendChild(popupMain);

        this.popup = document.getElementById("fp-main");
        this.popupMessage = document.getElementById("fp-message");
    }
    hidePopup() {
        this.popup.classList.remove("visible");
        setTimeout(function() {
            this.onPopupCooldown()
        }.bind(this), this.popupCooldownTime);
    }

    initLiveSignupCount(domId) {
        var target = document.getElementById(domId);
        try {
            if (!('readystate' in this.countSocket)) {
                this.countSocket = new WebSocket(this.baseUrl + '/ws/count');
            }

            this.countSocket.onmessage = function(msg) {
                var msgData = JSON.parse(msg.data);
                target.innerHTML = msgData["count"];
            }
        } catch (exception) {
            alert(exception);
        }
    }

    sendAction(action, name) {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", this.baseUrl.replace("ws:", "http:"), true);  // TODO https
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.send(JSON.stringify({
            "action": action,
            "name": name,
        }));
    }
}
