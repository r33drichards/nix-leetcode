test:
    nix-instantiate --eval leetcode.nix | jq -r 'fromjson | .'

w:
    watch "nix-instantiate --eval leetcode.nix | jq -r 'fromjson | .'"