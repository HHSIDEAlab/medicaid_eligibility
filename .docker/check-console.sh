if echo 'helper.time_ago_in_words 30.days.ago' | bundle exec rails c | grep -q 'about 1 month'; then
    echo "Console access works"
    exit 0
else
    echo "Console access does not work"
    exit 1
fi