if echo 'input="hello world"' | bundle exec rails c | grep -q 'hello world'; then
    echo "Console access works"
    exit 0
else
    echo "Console access does not work"
    exit 1
fi