# Couchbase Server Workshop

A hands-on workshop demonstrating key Couchbase features using local Docker clusters. This project provides practical exercises for XDCR (Cross Data Center Replication), alternative IP address configuration, server certificate setup, and more.

## Overview

This workshop sets up multiple Couchbase clusters locally to explore and experiment with various Couchbase features. Using Docker Compose, it creates three separate Couchbase clusters (A, B, C) with 3 nodes each, simulating real-world multi-datacenter and multi-node deployments.

## Features

- 🔧 **Easy Setup**: Quick deployment using Docker Compose
- 🌐 **Multi-Cluster Environment**: Three independent Couchbase clusters (9 nodes total)
- 🔄 **XDCR Scenarios**: Bidirectional replication, filtering, and advanced configurations
- 🌍 **Alternative IP Addresses**: Configure and test alternative node IPs for cluster communication
- 🔒 **Server Certificate Setup**: Secure clusters with custom server certificates
- 📚 **Step-by-Step Guides**: Detailed instructions for each feature
- 🛠️ **Automated Initialization**: All-in-one script to bootstrap clusters and configure buckets
- 🏠 **Local Development**: Runs entirely on localhost using host aliases

## Quick Start

1. Clone the repository and navigate to the project directory
2. Add host entries: `echo "127.0.0.1 a1.dev a2.dev a3.dev b1.dev b2.dev b3.dev c1.dev c2.dev c3.dev" >> /etc/hosts`
3. Initialize Couchbase clusters: `./setup.sh`
5. Access web consoles at `https://a1.dev:40011`, `https://b1.dev:40021`, `https://c1.dev:40031`

## Learning Objectives

- Understand and configure XDCR
- Set up and use alternative IP addresses in Couchbase clusters
- Configure server certificates for secure communication
- Explore other advanced Couchbase features
