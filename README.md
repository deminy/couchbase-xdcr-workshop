# Couchbase XDCR Workshop

A hands-on workshop demonstrating Cross Data Center Replication (XDCR) in Couchbase using local Docker clusters. This
project sets up multiple Couchbase clusters and walks through various XDCR scenarios including bidirectional
replication, filtering, and conflict resolution.

## Overview

This workshop provides a complete local environment to learn and experiment with Couchbase XDCR features without
requiring multiple physical data centers. Using Docker Compose, it creates three separate Couchbase clusters (A, B, C)
with 3 nodes each, simulating real-world multi-datacenter deployments.

## Features

- 🔧 **Easy Setup**: Quick deployment using Docker Compose
- 🌐 **Multi-Cluster Environment**: Three independent Couchbase clusters (9 nodes total)
- 🔄 **XDCR Scenarios**: Bidirectional replication, filtering, and advanced configurations
- 📚 **Step-by-Step Guides**: Detailed instructions for various replication patterns
- 🛠️ **Automated Initialization**: All-in-one script to bootstrap clusters and configure buckets
- 🏠 **Local Development**: Runs entirely on localhost using host aliases

## Quick Start

1. Clone the repository and navigate to the project directory
2. Add host entries: `echo "127.0.0.1 a1.dev a2.dev a3.dev b1.dev b2.dev b3.dev c1.dev c2.dev c3.dev" >> /etc/hosts`
3. Initialize Couchbase clusters: `./setup.sh`
5. Access web consoles at `https://a1.dev:40011`, `https://b1.dev:40021`, `https://c1.dev:40031`

## Learning Objectives

- Understand XDCR concepts and use cases
- Configure cross-datacenter replication between clusters
