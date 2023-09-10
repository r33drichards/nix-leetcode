# nix-leetcode

run 
```
nix-instantiate --eval leetcode.nix | jq -r 'fromjson | .'
```

or `just test`