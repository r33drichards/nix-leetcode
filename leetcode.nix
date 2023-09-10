#  nix-instantiate --eval leetcode.nix | jq -r 'fromjson | .'          

let 
  fac = self: acc: n: if n == 0 then acc else self (n * acc) (n - 1);
  pow2 = n: builtins.bitAnd n (n - 1) == 0;
  remainder = a: b:
    if a < b then a
    else remainder (a - b) b;
  sumDivisors = n: builtins.foldl'
    (runningsum: current: 
      if remainder n current == 0
      then current + runningsum 
      else runningsum)
    0 
    (if n == 1 then [] else 
      builtins.genList (x: x+1) (n - 2));   
  # https://leetcode.com/problems/perfect-number/
  perfectNumber = n: 
    if n < 6 then false
    else sumDivisors n == n;
  fib = n:
    if n == 0 then n else
    if n == 1 then n else
    fib(n - 1)+fib(n - 2);
  fibTCO = self: acc: n:
    if n == 0 then acc else
    if n == 1 then acc else
    self (acc + n) (n - 1);
  tco = import ./tco.nix;
  facTCO = n: tco fac 1 n;
  ftco = n: tco fibTCO 1 n;
  # https://leetcode.com/problems/take-gifts-from-the-richest-pile/
  sqrt = number: iterations: 
    let 
      nextGuess = guess: (guess + number / guess) / 2;
      improve = guess: 
        if iterations == 0 then guess
        else improve (nextGuess guess) (iterations - 1);
    in improve 1 iterations;
  # https://leetcode.com/problems/two-sum/
  twosum = nums: target:
    let 
      h = {};
      add = (h: k: v: h // {k = v;});
      get = (h: k: h.k);
    in 
      (builtins.foldl' 
        (acc: num: 
          let 
            complement = target - num;
          in 
            if builtins.length acc.ans > 0 then acc
            else
            if builtins.hasAttr (builtins.toString complement) h
            then acc // {
              ans = [get h complement acc.i];
            }
            else acc // {
              acc.h = add acc.h (builtins.toString complement) acc.i;
              i = acc.i + 1;
            }
        )
        {
          i = 0;
          h = h;
          ans = [];

        }
        nums).ans;

  # pickGifts = gifts: k:
in
  # using builtins.toJSON to eagerly evaluate the tests
  # jq then pretty prints the result
  builtins.toJSON {
    tests =[
      (assert remainder 10 3 == 1; "remainder works")
      (assert  perfectNumber 6; "six is perfect")
      (assert ! perfectNumber 7; "seven is not perfect")
      (assert pow2 33554432; "2^25 is a power of 2")
      (assert fib 1 == 1; "fib 1 is 1")
      (assert fib 2 == 1; "fib 2 is 1")
      (assert fib 3 == 2; "fib 3 is 2")
      (assert fib 4 == 3; "fib 4 is 3")
      (assert fib 5 == 5; "fib 5 is 5")
      (assert fib 6 == 8; "fib 6 is 8")
      (assert facTCO 15 == 1307674368000; "tail call optimized factorial works")
      (assert ftco 100 == 5050; "tail call optimized fibonacci works")
      # # nums = [2,7,11,15], target = 9
      # (assert twosum [2 7 11 15] 9 == [0 1]; "two sum works")
      # # Input: nums = [3,2,4], target = 6
      # # Output: [1,2]
      # (assert twosum [3 2 4] 6 == [1 2]; "two sum works")
      # # Input: nums = [3,3], target = 6
      # # Output: [0,1]
      # (assert twosum [3 3] 6 == [0 1]; "two sum works")

    ];
    twosum = twosum [2 7 11 15] 9;  
  }