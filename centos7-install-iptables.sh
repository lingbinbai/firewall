#!/bin/bash

firewalld_disable()
{
    sudo systemctl stop firewalld
    sudo systemctl disable firewalld
    sudo systemctl mask --now firewalld
}


iptables_install()
{

    sudo yum -y install iptables-services
    sudo systemctl start iptables
    sudo systemctl start ip6tables
    sudo systemctl enable iptables
    sudo systemctl enable ip6tables
}

iptables_status()
{
    sudo systemctl status iptables
    sudo systemctl status ip6tables

    sudo iptables -nvL
}


main()
{
    firewalld_disable
    iptables_install
    iptables_status
}

main $*
