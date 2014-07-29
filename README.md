crime-rescue
============

iOS app for receiving help when in danger. When feeling things are fishy, keep the button pressed. When danger strikes, just remove your finger off the button, the app does the rest. GPS location is sent to the server and the nearest app users are notified off the danger.

CrimeRescue can be used in 2 modes: Normal and Patrol. The normal mode is used by anyone who wants to receive help during emergency. The Patrol mode is used specifically by security forces - police, student patrol etc. The user in Patrol mode sends location updates while activated. This information is used by the server to send push notifications to nearest patrol units when a person in normal mode is in danger and requires help.

If a user in normal mode pressed the button by mistake, there is a 10 second timer that goes off before which the user password needs to be entered to disable the alarm. This makes sure that the offender does not forcibly disable the alarm on his own. 

Once the 10 second timer completes, alarm is raised and push notifications are sent to nearest patrol units. The location updates are also stored in Parse backend for later tracking purposes.
