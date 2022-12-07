# Radxa ROCK 5B

## Misc. Notes

Using a PD power supply is currently YMMV.

The FUSB302 driver *as configured and implemented* resets PD chargers when
probed. This is bad, since there is no other power source available.

This is not a Rock 5B specific issue, other designs using similar
"tablet-and-phones-first" power management ICs are susceptible to this problem.
