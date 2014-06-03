TogetherJSConfig_getUserName = function() {
  return $('.user_name').find('a').text();
}

TogetherJSConfig_getUserAvatar = function() {
  return $('.user_avatar').find('img').attr('src');
}

ready = function() {
  
  TogetherJS.config("siteName", "Wingolfsplattform");
  TogetherJS.refreshUserData();

}

$(document).ready(ready);
$(document).on('page:load', ready);
