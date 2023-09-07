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
surname = "Salzman"
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

This document seeks to specify a method for DNS servers to signal programs outside of the server software, and which are not necessarily involved with the DNS protocol, about conditions that can arise within the server.
These signals can be used to invoke actions in areas that help provide the DNS service, such as routing.

Currently this document serves as a requirements document to come to a signalling mechanism that will suit the use cases best.
Part of that effort is to assemble a list of conditions with potential associated out of DNS protocol actions, as well as inventory and assess existing signalling mechanisms for suitability.


{mainmatter}


# Introduction {#introduction}

Operators of DNS servers can benefit from automatically taking action upon certain conditions in the name server software.
Some conditions can be monitored from outside the server software, but for adequate and immediate action, the server software itself should signal about the condition immediately when it occurs to invoke action by a listener for these signals.

An example of such a condition is when all zones, from a set served from an anycasted prefix, are loaded and ready to be served.
An associated action may be to start announcing a prefix route from the point-of-presence where the name server is running and to withdraw the prefix route if one of the zones cannot be served anymore.
This way queries for zones will only reach the point-of-presence if the name server software can answer those queries.

Another example condition may be if an recursive resolver served from an anycasted prefix, is started and ready to serve, with the same associated action of only announcing the anycasted prefix when the recursive resolver can serve queries.

All anycasted DNS services can benefit from the mechanism alone, by the increased adequacy and reduced resources of not having to poll for a server's state.
DNS services with diverse implementations will benefit from standardizing of the name server signalling.

Before coming to a specification for the mechanism, this document will serve to inventorise the already available standardized and non-standardized signalling channels and assess them for usability for out of protocol signalling.

[//]: # (Recursive resolver operators also benefit from this, having an eventdriven infrastructure - when recursive server is ready to serve, start announcing the service address with BGP. The usual way to do this is by polling the server, and spending resources waiting for this service to come up.)

# Terminology and Definitions {#terminology}

The key words "**MUST**", "**MUST NOT**", "**REQUIRED**",
"**SHALL**", "**SHALL NOT**", "**SHOULD**", "**SHOULD NOT**",
"**RECOMMENDED**", "**NOT RECOMMENDED**", "**MAY**", and
"**OPTIONAL**" in this document are to be interpreted as described in
BCP 14 [@!RFC2119;@!RFC8174] when, and only when, they appear in all
capitals, as shown here.


# Conditions to be signalled {#conditions}

This section served to collect a list of conditions for which actions outside of the DNS protocol may be interesting.
A signal will be sent if the condition is met, and also when the condition is no longer met.
Some conditions take configuration parameters influencing when the conditions are met.
Some conditions may contain arguments when signalled.
When applicable, the parameters and arguments are given with each condition.

Some conditions may be identified from outside of the DNS server by polling for the condition.
This is more resource intensive that listening for a signal, but may also be more robust.
When this is the case, how the condition can be identified is provided with the condition.

## The DNS server is running and can respond to queries {#isrunning}

How to identify:

  - check if the DNS server is running by doing a query to see if it responds

Action:

  - Start announcing the prefix on which this zone is served with BGP
    A announcement may be withdrawn when the condition is no longer met.

## Shutting down {#shutdown}

How to identify:

  - Maintenance, before shutting down the name server, initiate at least the BGP withdrawl

Action:

  - Stop the BGP announcement of the prefix

## The nameserver has crashed {#crashed}

How to identify:

  - The name server is no longer running (or does not respond to queries, although that might also be the case when it is under an attack)

Action:

    - Stop the BGP announcement of the prefix

This condition maybe only detected from outside of the DNS server.

## A zone is loaded and ready to serve {#azoneready}

How to identify:

  - Query the zone to see if it responds

Argument:

  - The zone that was loaded

Action:

  - Start announcing the prefix on which these zones are served with BGP.
    A announcement may be withdrawn when the condition is no longer met.

Some name servers, when configured to notify targets when a zone is updated [@!RFC1996], will also notify those targets when a zone is just loaded.
The notify itself may be considered an appropriate signal, although it will not be emitted when the zone is no longer served.

## All zones are loaded and ready to serve {#allzonesready}

Action:

  - Start announcing the prefix on which these zones are served with BGP.
    A announcement may be withdrawn when the condition is no longer met.

This condition may be derived from one or more "A zone is loaded and ready to serve" ((#azoneready)) signals when a list of all zones served is available.

## A zone is updated to a new version {#updatedzone}

How to identify:

  - Query the zone's SOA record, register value and then compare to expected version

Argument:

  - The zone that was updated 

Action:

  - Verify the zone content. Is it DNSSEC valid, does the ZONEMD validate.

Name servers can usually already signal this with NOTIFY [@!RFC1996]

## A zone could not be refreshed {#norefresh}

How to identify:

  - logging might indicate a XFR failed.

Action:

  - Signal monitoring that there is a problem (maybe after X tries)


## A zone is (about to) expire

Parameter:

  - The period before expiration.
    A value of 0 will emit the signal the moment the zone expires.

Argument:

  - The zone that is (about to) expire

Action:

  - Stop the BGP announcement of the prefix on which the zone is served.
    It may be reannounced when the zone becomes available again (See (#azoneready)).

## DNSSEC signatures are (about to) expire

Parameter:

  - The period before expiration.
    A value of 0 will emit the signal the DNSSEC signature expires.

Argument:

  - The zone that contains the signature
  - The resource record set owner name and type with the signature that will soon expire

Action:

  - Stop the BGP announcement of the prefix on which the zone is served.
    It may be reannounced when the zone becomes DNSSEC valid again.

## Query rate is exceeding a threshold {#queryratehigh}

Parameter:

  - The number of queries per second threshold.

Action:

  - Lengthen the AS path for the BGP announcement for a prefix, to demotivate the anycast node that receives all the queries.
  - Or if the query rate is indicating a denial of service attack, keep the BGP AS path short, to absorb the attack.
  - Signal to Security Information and Event Management SIEM and logging that  problem has been observed.

## Query rate increase is exceeding a threshold {#queryrate_derivat}

Parameter:

  - The number of queries per second increase per second threshold.

Action:

  - The same actions as for "Query rate is exceeding a threshold" ((#queryratehigh)) apply.

## Extended DNS Error conditions {#ede}

Parameter:

  - The Extended DNS Error conditions for which to signal [@!RFC8914]

Argument:

  - The Extended DNS Error condition that occurred.

Action:

  - Dependent on the DNS Error condition



# Requirements for signalling mechanisms and channels {#requirements}

- All conditions are sensitive information and should be stay either in the administered domain (for example on the local machine that is under control of the operator), or needs to be authenticated.

# Existing signalling mechanisms and channels {#existing}

What follows is a list of existing signalling mechanisms and a comparison of those channels in (#comparison).

## Notify

DNS NOTIFY [@!RFC1996] is an existing ubiquitous mechanism to signal zones.
It is intended to target name servers, but tooling exists to listen for NOTIFY messages and trigger execution of a command when a zone is updated (See [@?nsnotifyd]).

Advantages:

  - Native signalling for zone updates present right now (See (#updatedzone))

  - Indirect support for zone loaded (See (#azoneready))

Disadvantages:

  - One available Open Source Software which lacks authentication support and is therefore only suitable for local usage

  - Only two conditions are signalled.

  - Does not signal when the conditions are no longer met.

## D-Bus as publication channel {#dbus}

D-Bus is a mechanism for exchanging messages between processes local on the same machine (See [@?D-Bus]).
The D-BUS protocol is a one-to-one protocol, but distribution of messages (or signals) to multiple other applications is carried out by a program intended for this purpose: the D-Bus *message bus*.

Advantages:

  - Implementation already exists (See [@?Knot-DNS-3.1.6])

  - Good Open Source Software library support [TODO references]

Disadvantages:

  - Server needs to be started before clients making it less robust.

  - Is only communicated locally to the machine

## DDoS Open Threat Signaling

DDoS Open Threat Signaling (DOTS) [@!RFC9132,8783] is a set of protocols for real-time signaling of threat-mitigation requests within and between different operational domains.

Advantages:

  - Publish / Subscribe mechanism

  - Inter-operator communications

  - Authenticated

  - Open Source server software exists [TODO reference go-dots]

Disadvantages:

  - No Open Source client library exists? We need to get information during the upcoming hackathon at the IETF117.
    Current DOTS builds upon CoAP [@!RFC7252] for which many client library implementations exist.

## MQTT

MQTT (see [@?MQTT-OASIS-Standard-v5]) is a lightweight publish-subscribe network protocol for messages.

Advantages:

  - Network Publish / Subscribe mechanism

  - Supports authentication 


Disadvantages:

  - Need to gain experience at the IETF117 hackathon

## Observations and comparison {#comparison}

Method                      | NOTIFY | D-Bus | DOTS | MQTT |
----------------------------|--------|-------|------|------|
Local to machine            | +      | ++    | +    | +    |
inter-machine               | +      | -     | +    | +    |
inter-operator              | +      | -     | ++   | -    |
Publish Subscribe           | -      | -     | ++   | ++   |
Authentication              | +-     | -     | +    | +    |
Client library availability | NA     | ++    | ?    | ++   |

# Security and Privacy Considerations {#security}

Signalling MUST be performed in an authenticated and private manner.

# Implementation Status {#implementation}

* Knot DNS has support for D-Bus notifications (See (#dbus)) for significant server and zone events with the "`dbus-event`" configuration parameter since version 3.1.6 [@?Knot-DNS-3.1.6]
* NSD has a feature branch [@?NSD-oops-branch] where work is being done on the implementation

# IANA Considerations {#iana}

This document has no IANA actions


# Acknowledgements {#acknowledgements}

We would like to thank the people of the DNS Hackathon 2023 - Connect to port
53 in Rotterdam for
their contributions. Mainly Doris Hauser, Lars-Johan Liman, Vilhelm Prytz and
Henrik Kramselund




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

<reference anchor="NSD-oops-branch" target="https://github.com/NLnetLabs/nsd/tree/features/oops">
  <front>
    <title>NSD feature/oops branch</title>
    <author>
      <organization>NLnet Labs</organization>
    </author>
    <date month="May" year="2023" />
  </front>
</reference>

<reference anchor="nsnotifyd" target="https://dotat.at/prog/nsnotifyd/">
  <front>
    <title>nsnotifyd: scripted DNS NOTIFY handler</title>
    <author fullname="Tony Finch" initials="T." surname="Finch" />
    <date month="Jan" year="2022" />
  </front>
</reference>

<reference anchor="MQTT-OASIS-Standard-v5" target="https://docs.oasis-open.org/mqtt/mqtt/v5.0/os/mqtt-v5.0-os.html">
  <front>
    <title>OASIS Standard MQTT Version 5.0</title>
    <author fullname="Andrew Banks" initials="A." surname="Banks">
      <organization>IBM</organization>
    </author>
    <author fullname="Ed Briggs" initials="E." surname="Briggs">
      <organization>Microsoft</organization>
    </author>
    <author fullname="Ken Borgendale" initials="K." surname="Borgendale">
      <organization>IBM</organization>
    </author>
    <author fullname="Raphul Gupta" initials="R." surname="Gupta">
      <organization>IBM</organization>
    </author>
    <date day="19" month="Mar" year="2019" />
  </front>
</reference>

{backmatter}


# Implementation Status {#implementation}

**Note to the RFC Editor**: please remove this entire appendix before publication.

Knot currently uses [@D-Bus] for this.

# Change History {#change}

**Note to the RFC Editor**: please remove this entire appendix before publication.

* draft-grubto-dnsop-dns-out-of-protocol-signalling-03

> Rename "name server" into "DNS server" when it also applies to recursive resolvers

> Make a single list of conditions with per condition indicated the parameters (how they can be influenced by configuration), the arguments (the signal payload) and "how to identify" if the condition can be identified from outside of the DNS server.

> Removing DNS Error reporting monitoring agent as a channel to evaluate

> Add DOTS and MQTT as a potential signal channels for our conditions

* draft-grubto-dnsop-dns-out-of-protocol-signalling-02

> Updates after discussion during the port53 hackathon in Rotterdam.


* draft-grubto-dnsop-dns-out-of-protocol-signalling-00

> Initial version
