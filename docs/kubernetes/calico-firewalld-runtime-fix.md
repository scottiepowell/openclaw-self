# Calico + firewalld runtime recovery notes

## Incident summary

The Kubernetes cluster experienced asymmetric and cross-node pod networking
failures affecting:

- CoreDNS reachability
- pod-to-pod TCP traffic
- Service DNS resolution
- Cloudflare tunnel workloads
- wger init containers waiting on DNS/service names

The highest-confidence root cause identified during recovery was host-level
forward filtering interacting badly with Calico VXLAN/pod forwarding.

## Runtime fixes that restored traffic

These were applied live during recovery and should be converted into permanent
node configuration management.

### firewalld trusted pod CIDR

```bash
firewall-cmd --zone=trusted --add-source=10.244.0.0/16
```

### firewalld trusted Calico VXLAN interface

```bash
firewall-cmd --zone=trusted --add-interface=vxlan.calico
```

### Allow VXLAN UDP traffic

```bash
firewall-cmd --zone=public --add-port=4789/udp
```

### Relax rp_filter for Calico interfaces

```bash
for f in /proc/sys/net/ipv4/conf/cali*/rp_filter; do
  echo 0 > "$f"
done

echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter
echo 0 > /proc/sys/net/ipv4/conf/default/rp_filter
echo 0 > /proc/sys/net/ipv4/conf/vxlan.calico/rp_filter
```

## Next engineering step

Do not rely on runtime-only shell fixes.

Persist these through:

- Ansible
- ignition/cloud-init
- systemd unit
- NetworkManager dispatcher
- firewalld permanent config
- node bootstrap automation

Validate after reboot:

```bash
kubectl exec -n guacamole netshoot-guacamole -- sh -lc '
  nc -vz -w 5 10.244.37.220 5432
'
```

and:

```bash
kubectl exec -n fitness netshoot-worker02-afterbgp -- sh -lc '
  dig @10.96.0.10 kubernetes.default.svc.cluster.local A +time=2 +tries=1
'
```
