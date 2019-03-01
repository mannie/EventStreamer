FROM swift
ENV SASPolicyName=""
ENV SASPolicyKey=""
ENV EventHubNamespace=""
ENV EventHubPath=""
WORKDIR /temp
COPY . ./
CMD swift package clean
CMD swift run
