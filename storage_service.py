import grpc
from api.v1.proto.deployment_environment_service_pb2_grpc import (
    DeploymentEnvironmentServiceStub,
)
from api.v1.proto.deployment_service_pb2_grpc import DeploymentServiceStub
from api.v1.proto.experiment_service_pb2_grpc import ExperimentServiceStub
from api.v1.proto.gateway_aggregator_service_pb2_grpc import (
    GatewayAggregatorServicesStub,
)
from api.v1.proto.project_service_pb2_grpc import ProjectServiceStub
from api.v1.proto.registered_model_service_pb2_grpc import RegisteredModelServiceStub
from api.v1.proto.registered_model_version_service_pb2_grpc import (
    RegisteredModelVersionServiceStub,
)
from api.v1.proto.role_service_pb2_grpc import RoleServiceStub
from api.v1.proto.user_service_pb2_grpc import UserServiceStub


class StorageService:
    def __init__(self, certificate: str, key: str, ca: str, url: str):
        channel_creds = grpc.ssl_channel_credentials(
            root_certificates=bytes(ca, "utf-8"),
            private_key=bytes(key, "utf-8"),
            certificate_chain=bytes(certificate, "utf-8"),
        )
        channel = grpc.secure_channel(
            target=url,
            credentials=channel_creds,
        )

        self.aggregator_service = GatewayAggregatorServicesStub(channel)
        self.project_service = ProjectServiceStub(channel)
        self.model_service = RegisteredModelServiceStub(channel)
        self.experiment_service = ExperimentServiceStub(channel)
        self.deployment_service = DeploymentServiceStub(channel)
        self.model_version_service = RegisteredModelVersionServiceStub(channel)
        self.deployment_env_service = DeploymentEnvironmentServiceStub(channel)
        self.role_service = RoleServiceStub(channel)
        self.user_service = UserServiceStub(channel)
