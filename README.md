[![Travis (.org) branch](https://img.shields.io/travis/ccztux/modpd/master?label=shellcheck%28master%29)](https://travis-ci.org/ccztux/modpd)
[![Travis (.org) branch](https://img.shields.io/travis/ccztux/modpd/devel?label=shellcheck%28devel%29)](https://travis-ci.org/ccztux/modpd)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/ccztux/modpd?label=latest%20release)](https://github.com/ccztux/modpd/releases/latest)
[![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/ccztux/modpd?include_prereleases&label=latest%20pre-release)](https://github.com/ccztux/modpd/releases/tag/1.0.2-beta1)
[![GitHub](https://img.shields.io/github/license/ccztux/modpd?color=yellowgreen)](https://github.com/ccztux/modpd/blob/master/LICENSE)



# modpd
(**M**onitoring **O**bsessing **D**ata **P**rocessor **D**aemon)

You can use modpd with send_nrdp.php or send_nsca. It increases the performance of an existing Nagios 3.x.x installation greatly, because the obsessing commands will be executed by modpd and not by the nagios process itself. Nagios executes the obsessing command after every check, where obsessing is activated and then Nagios waits, till every obsessing command was executed successfully or timed out.


# TODO:
Add the eventbroker module for Nagios 3.x.x needed by modpd.
