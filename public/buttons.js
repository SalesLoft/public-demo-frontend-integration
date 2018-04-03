// This script prevents links from hijacking the window history of SalesLoft
(function() {
  var elements = document.getElementsByTagName('a');
  for(var i = 0, len = elements.length; i < len; i++) {
    elements[i].onclick = function () {
      window.location.replace(this.href);
      return false;
    }
  }
})();
