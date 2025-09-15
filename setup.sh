#!/usr/bin/env bash
#
# An all-in-one script to set up three Couchbase clusters (a1.dev, b1.dev, c1.dev), each with three nodes.
#

set -ex

CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
cd "${CURRENT_DIR}/"

# Force to recreate Docker containers.
docker compose down -v --remove-orphans || true
docker compose up -d --force-recreate

for cluster in "a" "b" "c" ; do
  cluster_name="${cluster}1.dev"
  for index in {1..3} ; do
    node_name="${cluster}${index}.dev"

    # Create Couchbase data directories.
    docker compose exec -ti ${node_name} bash -c "mkdir -p /mnt/couchbase/data /mnt/couchbase/indexes /mnt/couchbase/analytics /mnt/couchbase/eventing; chown -R couchbase:couchbase /mnt/couchbase"

    # Wait until the Couchbase server is ready to accept connections.
    while ! docker compose exec -ti ${node_name} curl -sf --output /dev/null http://127.0.0.1:8091 ; do
        sleep 2
    done

    # Initialize a Couchbase node.
    #
    # @see https://docs.couchbase.com/server/current/cli/cbcli/couchbase-cli-node-init.html
    docker compose exec -ti ${node_name} /opt/couchbase/bin/couchbase-cli \
      node-init \
      --cluster ${node_name}:8091 \
      --username 'username' \
      --password 'password' \
     --ipv4 \
     --node-init-hostname ${node_name} \
     --node-init-data-path /mnt/couchbase/data \
     --node-init-index-path /mnt/couchbase/indexes \
     --node-init-analytics-path /mnt/couchbase/analytics \
     --node-init-eventing-path /mnt/couchbase/eventing

    # Each Couchbase cluster has 3 nodes. If this is the first node, initialize the cluster and create buckets. If this
    # is the second or third node, add it to the cluster.
    if [[ $index -eq 1 ]] ; then
      # Initialize the Couchbase cluster.
      #
      # @see https://docs.couchbase.com/server/current/cli/cbcli/couchbase-cli-cluster-init.html
      docker compose exec -ti ${node_name} /opt/couchbase/bin/couchbase-cli \
        cluster-init \
        --cluster ${cluster_name}:8091 \
        --cluster-name ${cluster_name} \
        --cluster-username 'username' \
        --cluster-password 'password' \
        --cluster-port 8091 \
        --services data \
        --update-notifications 0 \
        --ip-family ipv4 \
        --node-to-node-encryption off

      # Create a second admin user for the Couchbase cluster.
      docker compose exec -ti ${node_name} /opt/couchbase/bin/couchbase-cli \
        user-manage \
        --cluster ${cluster_name}:8091 \
        --username 'username' \
        --password 'password' \
        --set \
        --rbac-username 'admin' \
        --rbac-password 'password' \
        --roles 'admin' \
        --auth-domain local

      # Create buckets in the Couchbase cluster.
      #
      # @see https://docs.couchbase.com/server/current/cli/cbcli/couchbase-cli-bucket-create.html
      for bucket_name in "test1" "test2" ; do
        docker compose exec -ti ${node_name} /opt/couchbase/bin/couchbase-cli \
          bucket-create \
          --cluster ${cluster_name}:8091 \
          --username 'username' \
          --password 'password' \
          --bucket ${bucket_name} \
          --bucket-type couchbase \
          --bucket-ramsize 100 \
          --compression-mode active \
          --enable-flush 1 \
          --wait

        # Create a user for each bucket with "data_reader" role.
        docker compose exec -ti ${node_name} /opt/couchbase/bin/couchbase-cli \
          user-manage \
          --cluster ${cluster_name}:8091 \
          --username 'username' \
          --password 'password' \
          --set \
          --rbac-username ${bucket_name} \
          --rbac-password 'password' \
          --roles "data_reader[${bucket_name}]" \
          --auth-domain local
      done
    else
      # Add new node to the cluster.
      #
      # When using command "server-add",
      #   1. HTTP is prohibited due to security reasons, please use https.
      #   2. Short names like "a2" are not allowed. We need to use a fully qualified domain name.
      #
      # @see https://docs.couchbase.com/server/current/cli/cbcli/couchbase-cli-server-add.html
      docker compose exec -ti ${node_name} /opt/couchbase/bin/couchbase-cli \
        server-add \
        --cluster ${cluster_name}:8091 \
        --username 'username' \
        --password 'password' \
        --server-add https://${node_name}:18091 \
        --server-add-username 'username' \
        --server-add-password 'password' \
        --services data
    fi
  done

  # Rebalance data across nodes in the cluster.
  #
  # @see https://docs.couchbase.com/server/current/cli/cbcli/couchbase-cli-rebalance.html
  docker compose exec -ti ${node_name} /opt/couchbase/bin/couchbase-cli \
    rebalance \
    --cluster ${cluster_name}:8091 \
    --username 'username' \
    --password 'password' \
    --no-progress-bar
done

# Set up XDCR (Cross Data Center Replication) between clusters.
#
# @param $1 Source cluster name, which is also host name of the first node in the cluster, e.g., a1.dev.
# @param $2 Target cluster name, which is also host name of the first node in the cluster, e.g., b1.dev.
function xdcr() {
  source=$1
  target=$2

  docker compose exec -ti $source /opt/couchbase/bin/couchbase-cli \
    xdcr-setup \
    --cluster $source:8091 \
    --username 'username' \
    --password 'password' \
    --create \
    --xdcr-cluster-name $target \
    --xdcr-hostname $target \
    --xdcr-username 'username' \
    --xdcr-password 'password' \
    --xdcr-secure-connection 'none'

  docker compose exec -ti $source /opt/couchbase/bin/couchbase-cli \
    xdcr-replicate \
    --cluster $source:8091 \
    --username 'username' \
    --password 'password' \
    --create \
    --xdcr-cluster-name $target \
    --xdcr-from-bucket test1 \
    --xdcr-to-bucket   test1
}

xdcr a1.dev b1.dev
xdcr b1.dev c1.dev

echo Done.
