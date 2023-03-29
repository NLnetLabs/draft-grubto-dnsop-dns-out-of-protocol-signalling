%%%
Title = "DNS Out Of Protocol Signalling"
abbrev = "dns-oops"
docname = "@DOCNAME@"
category = "std"
ipr = "trust200902"
area = "Internet"
workgroup = "DNSOP Working Group"
date = @TODAY@

[seriesInfo]
name = "Internet-Draft"
value = "@DOCNAME@"
stream = "IETF"
status = "standard"

[[author]]
initials = "C."
surname = "Almond"
fullname = "Cathy Almond"
organization = "Internet Systems Consortium, Inc."
abbrev = "ISC"
[author.address]
 email = "cathya@isc.org"
 phone = "+1 650 423 1300"
[author.address.postal]
 street = "PO Box 360"
 city = "Newmarket"
 code = "NH 03857"
 country = "United States of America"

[[author]]
initials = "P."
surname = "van Dijk"
fullname = "Peter van Dijk"
organization = "PowerDNS"
[author.address]
 email = "peter.van.dijk@powerdns.com"
[author.address.postal]
 city = "Den Haag"
 country = "Netherlands"

[[author]]
initials = "M.W."
surname = "Groeneweg"
fullname = "Marc Groeneweg"
organization = "Stichting Internet Domeinregistratie Nederland"
abbrev = "SIDN"
[author.address]
 email = "marc.groeneweg@sidn.nl"
[author.address.postal]
 street = "Postbus 5022"
 city = "Arnhem"
 code = "6802EA"
 country = "Netherlands"

[[author]]
initials = "S.W.J."
surname = "Ubbink"
fullname = "Stefan Ubbink"
organization = "Stichting Internet Domeinregistratie Nederland"
abbrev = "SIDN"
[author.address]
 email = "stefan.ubbink@sidn.nl"
[author.address.postal]
 street = "Postbus 5022"
 city = "Arnhem"
 code = "6802EA"
 country = "Netherlands"

[[author]]
initials = "D."
surname = "Daniel"
fullname = "Daniel Salzman"
organization = "CZ.NIC"
[author.address]
 email = "daniel.salzman@nic.cz"
[author.address.postal]
 country = "CZ"

[[author]]
initials="W."
surname="Toorop"
fullname="Willem Toorop"
organization = "NLnet Labs"
[author.address]
 email = "willem@nlnetlabs.nl"
[author.address.postal]
 street = "Science Park 400"
 city = "Amsterdam"
 code = "1098 XH"
 country = "Netherlands"

%%%


.# Abstract

This document seeks to specify a method for name servers to signal programs outside of the name server software, and which are not necessarily involved with the DNS protocol, about conditions that can arise within the name server.
These signals can be used to invoke actions in areas that help provide the DNS service, such as routing.

Currently this document serves as a requirements document to come to a signalling mechanism that will suit the use cases best.
Part of that effort is to assemble a list of conditions with potential associated out of DNS protocol actions, as well as inventory and assess existing signalling mechanisms for suitability.


{mainmatter}


# Introduction {#introduction}

Operators of name servers can benefit from automatically taking action upon certain conditions in the name server software.
Some conditions can be monitored from outside the name server software, but for adequate and immediate action, the name server software can signal itself about the condition immediately when it occurs to invoke action by a listener for these signals.

An example of such a condition is when all zones, from a set served from an anycasted prefix, are loaded and ready to be served, with the associated automatic actions to only announce a prefix route from the point-of-presence where the name server is running, if all zones from the set are ready to be served, and to withdraw the prefix route if one of the zones cannot be served.
This way queries for zones will only reach the point-of-presence if the name server software can answer those queries.

Operators of anycasted DNS authoritative services with diverse implementations will benefit from standardizing of the name server signalling, but before coming to a specification for the mechanism, this document will serve to inventorise the already available standardized and non-standardized signalling channels and assess them for usability for out of protocol signalling.


# Terminology and Definitions {#terminology}

The key words "**MUST**", "**MUST NOT**", "**REQUIRED**",
"**SHALL**", "**SHALL NOT**", "**SHOULD**", "**SHOULD NOT**",
"**RECOMMENDED**", "**NOT RECOMMENDED**", "**MAY**", and
"**OPTIONAL**" in this document are to be interpreted as described in
BCP 14 [@!RFC2119;@!RFC8174] when, and only when, they appear in all
capitals, as shown here.


# Conditions to be signalled {#conditions}

This section served to collect a list of conditions for which actions outside of the DNS protocol may be interesting.
It is by no means meant to be a complete list, but serves to inventorise the requirements for the signalling channel.

## The name server is running and can respond to queries

## All zones are loaded and ready to serve {#allzonesready}

Action:

  - Start announcing the prefix on which these zones are served with BGP.

## A zone is loaded and ready to serve

Action:

  - Start announcing the prefix on which this zone is served with BGP.

## A zone is updated to a new version {#updatedzone}

Action:

  - Verify the zone content.
    Is it DNSSEC valid, does the ZONEMD validate.

## A zone is (about to) expire

The period before expiration may be configurable.
A value of 0 will emit the signal the moment the zone expires.

Action:

  - Stop the BGP announcement of the prefix on which the zone is served.
    It may be reannounced when the zone becomes available again (See (#allzonesready)).

## DNSSEC signatures are (about to) expire

The period before expiration may be configurable.
A value of 0 will emit the signal the DNSSEC signature expires.

Action:

  - Stop the BGP announcement of the prefix on which the zone is served.
    It may be reannounced when the zone becomes DNSSEC valid again (See (#dnssecokagain)).

## DNSSEC signatures will no longer expire soon {#dnssecokagain}

Action:

  - Start announcing the prefix on which this zone is served with BGP.

## Query rate is exceeding a threshold {#queryratehigh}

Action:

  - Lengthen the AS path for the BGP announcement for a prefix, to demotivate the anycast node that receives all the queries.
  - Or if the query rate is indicating a denial of service attack, keep the BGP AS path short, to absorb the attack.

## Query rate is below a threshold again

Action:

  - Recover from the measures taken in (#queryratehigh)

## Extended DNS Error conditions

Action:

  - Dependent on the DNS Error condition

# Requirements for signalling mechanisms and channels {#requirements}

The following requirements can be distilled from (#conditions).


# Existing signalling mechanisms and channels {#existing}

What follows is a list of existing signalling mechanisms assessed on their suitability based on the requirements outlined in the previous paragraph.

## Notify

[@RFC1996]

## Extended DNS Error reporting

[@?I-D.ietf-dnsop-dns-error-reporting]

## D-Bus as publication channel {#dbus}

[@?D-Bus]

# Security and Privacy Considerations {#security}

Signalling MUST be performed in an authenticated and private manner.

# Implementation Status {#implementation}

* Knot DNS has support for D-Bus notifications (See (#dbus)) for significant server and zone events with the "`dbus-event`" configuration parameter since version 3.1.6 [@?Knot-DNS-3.1.6]

# IANA Considerations {#iana}

This document has no IANA actions


# Acknowledgements {#acknowledgements}



<reference anchor="D-Bus" target="https://dbus.freedesktop.org/doc/dbus-specification.html">
  <front>
    <title>D-Bus Specification</title>
    <author fullname="Havoc Pennington" initials="H." surname="Pennington">
      <organization>Red Hat, Inc.</organization>
    </author>
    <author fullname="Anders Carlsson" initials="A." surname="Carlsson">
      <organization>CodeFactory AB</organization>
    </author>
    <author fullname="Alexander Larsson" initials="A." surname="Larsson">
      <organization>Red Hat, Inc.</organization>
    </author>
    <author fullname="Sven Herzberg" initials="S." surname="Herzberg">
      <organization>Imendio AB</organization>
    </author>
    <author fullname="Simon McVittie" initials="S." surname="McVittie">
      <organization>Collabora Ltd.</organization>
    </author>
    <author fullname="David Zeuthen" initials="D." surname="Zeuthen" />
    <date month="February" year="2023" />
  </front>
</reference>


<reference anchor="Knot-DNS-3.1.6" target="https://www.knot-dns.cz/2022-02-08-version-316.html">
  <front>
    <title>Knot DNS - Version 3.1.6</title>
    <author>
      <organization>CZ.NIC</organization>
    </author>
    <date month="February" year="2022" />
  </front>
</reference>

{backmatter}


# Implementation Status {#implementation}

**Note to the RFC Editor**: please remove this entire appendix before publication.

Knot currently uses [@D-Bus] for this.

# Change History {#change}

**Note to the RFC Editor**: please remove this entire appendix before publication.

* draft-grubto-dnsop-dns-out-of-protocol-signalling-00

> Initial version
