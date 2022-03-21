# fyp_flutter

MomoManager - A portfolio allocation app using DRL-FinRL and PyPfOpt to perform portfolio allocation strategies.

## Attribution

<div>Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a></div>

# This Application is split into three components

1. Firebase Server [Storage]
2. Local Server    [Computation]
3. Flutter App     [Display]

1. Firebase Server Setup
- Create a Firebase app, add the generated google services json into the flutter application
- Enable email authentication

2. Local Server
- Install requirements listed in "requirements.txt"
- Run api.py using a windows terminal (other OS not tested)

3. Flutter App
- Open the flutter directory in VSCode
- Ensure that an android virtual device with SDK 29 is created
- Run the application.