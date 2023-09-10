test:
    nix-instantiate --eval leetcode.nix | jq -r 'fromjson | .'
