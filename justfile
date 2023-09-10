test:
    nix-instantiate --eval leetcode.nix | jq -r 'fromjson | .'

wtest:
    watch "nix-instantiate --eval leetcode.nix | jq -r 'fromjson | .'"