SimplePoll : UGen {
    *ar { |sig, pollRate|
        ^this.multiNew('audio', sig, pollRate);
    }
    checkInputs {
        (inputs[0].rate != 'audio').if {
              ^"input % is not audio rate".format(0).throw;
        };
        ^this.checkValidInputs;
    }
}
