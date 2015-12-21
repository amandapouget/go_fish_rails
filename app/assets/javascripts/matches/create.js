$(document).ready(function() {
  if (document.body.contains(document.getElementById('data-marker')) && document.getElementById('data-marker').getAttribute('data-page') === "matches/create") {
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
      var readyTracker = new ReadyTracker();
      var pusher = new Pusher('39cc3ae7664f69e97e12', { encrypted: true });
      var userId = $("#game_info").data("user_id");
      var numberOfPlayers = $("#game_info").data("num_players");
      var waitingView = new WaitingView();
      var channel = pusher.subscribe('waiting_for_players_channel_' + userId);
      channel.bind('pusher:subscription_succeeded', function() {
        $.post('/subscribed', { id: userId, num_players: numberOfPlayers });
        waitingView.setPlayWithRobots();
        readyTracker.setReadyOn();
      });
      channel.bind('send_to_game_event', function(data) {
        window.location = "../matches/" + data["message"]
      });
    };
    documentIsReady();
  }
});
