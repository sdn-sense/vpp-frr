1. Go to SENSE-O and use `NRP-CERN-to-NRP-SDSC (via ESnet)`
2. Show some SENSE Information and GUI - Details, Visualization, and that it goes to each RM and submits request. 
3. While SENSE Requests prepares to commit, show what is comming next with Network attachements and Pods on either side;
4. Once SENSE path is ready - create Real Time Monitoring, which will be shown later;
4. Apply both:
    kubectl apply -f net-attach-def.yaml --kubeconfig ~/.kube/config-ucsd
    kubectl apply -f pod.yaml --kubeconfig ~/.kube/config-ucsd
5. Open 2 terminals and go to each container, issue ping
6. Issue network test:
      java -jar fdt.jar -nettest
      java -jar fdt.jar -c 10.1.11.52 -nettest -P 4
7. Show monitoring link, graphs, L2 debugging, we are working on integrating all fabric monitoring soon. Show link going to ESnet Oscars - and oscars view - which allows us to attach custom link from network providers.
8. Go to demo3;

