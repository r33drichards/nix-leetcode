# https://discourse.nixos.org/t/tail-call-optimization-in-nix-today/17763
f:
let
  lib = import <nixpkgs/lib>;
  # we'll use a fixed point and tail recursion
  fac = self: acc: n: if n == 0 then acc else self (n * acc) (n - 1);
  apply = f: args: builtins.foldl' (f: x: f x) f args;

  unapply =
    let
      unapply' = acc: n: f: x:
        if n == 1
        then f (acc ++ [ x ])
        else unapply' (acc ++ [ x ]) (n - 1) f;
    in
    unapply' [ ];
  argCount = f:
    let
      # N.B. since we are only interested if the result of calling is a function
      # as opposed to a normal value or evaluation failure, we never need to
      # check success, as value will be false (i.e. not a function) in the
      # failure case.
      called = builtins.tryEval (
        f (builtins.throw "You should never see this error message")
      );
    in
    if !(builtins.isFunction f || builtins.isFunction (f.__functor or null))
    then 0
    else 1 + argCount called.value;
  tailCallOpt = f:
    let
      argc = argCount (lib.fix f);

      # This function simulates being f for f's self reference. Instead of
      # recursing, it will just return the arguments received as a specially
      # tagged set, so the recursion step can be performed later.
      fakef = unapply argc (args: {
        __tailCall = true;
        inherit args;
      });
      # Pass fakef to f so that it'll be called instead of recursing, ensuring
      # only one recursion step is performed at a time.
      encodedf = f fakef;

      # This is the main function, implementing the “optimized” recursion
      opt = args:
        let
          steps = builtins.genericClosure {
            # This is how we encode a (tail) call: A set with final == false
            # and the list of arguments to pass to be found in args.
            startSet = [
              {
                key = "0";
                id = 0;
                final = false;
                inherit args;
              }
            ];

            operator =
              { id, final, ... }@state:
              let
                # Generate a new, unique key to make genericClosure happy
                newIds = {
                  key = toString (id + 1);
                  id = id + 1;
                };

                # Perform recursion step
                call = apply encodedf state.args;

                # If call encodes a new call, return the new encoded call,
                # otherwise signal that we're done.
                newState =
                  if builtins.isAttrs call && call.__tailCall or false
                  then newIds // {
                    final = false;
                    inherit (call) args;
                  } else newIds // {
                    final = true;
                    value = call;
                  };
              in

              if final
              then [ ] # end condition for genericClosure
              else [ newState ];
          };
        in
        # The returned list contains intermediate steps we need to ignore
        (builtins.head (builtins.filter (x: x.final) steps)).value;
    in
    # make it look like a normal function again
    unapply argc opt;
in
tailCallOpt f
# => 1307674368000