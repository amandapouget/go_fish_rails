$(document).ready(function() {
  console.log("ON A DOC");
  if (document.body.contains(document.getElementById('data-marker')) && document.getElementById('data-marker').getAttribute('data-page') === "matches/new") {
    function WaitingView() {
    }

    WaitingView.prototype.setPlayWithRobots = function() {
      var startButton = document.createElement('button');
      startButton.type = 'submit';
      startButton.className = 'button';
      startButton.innerText = 'Play With Robots';
      var robotForm = document.getElementById('robot_form');
      robotForm.appendChild(startButton);
    }

    var documentIsReady = function() {
      console.log("GOT DOC READY");
      var readyTracker = new ReadyTracker();
      var pusher = new Pusher('39cc3ae7664f69e97e12', { encrypted: true });
      var userId = $("#data-marker").data("user_id");
      var waitingView = new WaitingView();
      var channel = pusher.subscribe('waiting_for_players_channel_' + userId);
      channel.bind('pusher:subscription_succeeded', function() {
        readyTracker.setReadyOn();
        console.log("SUBSCRIBED!");
      });
      channel.bind('send_to_game_event', function(data) {
        window.location = "../matches/" + data["message"]
      });
    };
    documentIsReady();
  }
});
