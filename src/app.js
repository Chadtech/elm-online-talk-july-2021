var app = Elm.Main.init();

function toElm(type, body) {
	app.ports.fromJs.send({
		type: type,
		body: body
	});
}







var actions = {
	analytics_event: function(payload) {
        var eventName = payload.eventName;
        var props = payload.props;

        console.log("TRACK", eventName, props);
    }
}

function jsMsgHandler(msg) {
	var action = actions[msg.type];
	if (typeof action === "undefined") {
		console.log("Unrecognized js msg type ->", msg.type);
		return;
	}
	action(msg.body);
}

app.ports.toJs.subscribe(jsMsgHandler)

