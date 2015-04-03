# In order to handle cache_keys properly, we need to store timestamps
# with µs precision.
#
# Trello: https://trello.com/c/jh6CpwdX/811-caching-zeit-auflosung
# 
# Gist: https://gist.github.com/iamatypeofwalrus/d074d22a736d49459b15
#
Time::DATE_FORMATS.merge!({ db: '%Y-%m-%d %H:%M:%S.%6N' })
