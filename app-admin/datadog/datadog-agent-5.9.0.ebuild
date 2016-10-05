# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

DESCRIPTION="The Datadog Agent faithfully collects events and metrics and brings them to Datadog on your behalf so that you can do something useful with your monitoring and performance data"
HOMEPAGE="http://datadoghq.com/"
SRC_URI="https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh"
LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"
#https://raw.githubusercontent.com/DataDog/dd-agent/$AGENT_VERSION

# Datadog install script vars
AGENT_VERSION=${PV}
DD_START_AGENT=0

DEPEND="dev-lang/python:2.7
	app-admin/sysstat"
RDEPEND="dev-lang/python
	app-admin/sysstat
	dev-python/virtualenv"

S="${WORKDIR}"

src_install(){
	chmod +x install_agent.sh
	DD_HOME=${S}
	install_agent.sh ${PV}
}
