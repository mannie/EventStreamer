FROM swift
ENV SASPolicyName=""
ENV SASPolicyKey=""
ENV EventHubNamespace=""
ENV EventHubName=""
WORKDIR /temp
COPY . ./
CMD swift package clean
CMD swift run
