from typing import List, Tuple

from storage_service import StorageService
from api.v1.proto.deployment_service_pb2 import CountDeploymentsRequest, CountDeploymentsResponse
from api.v1.proto.listing_pb2 import PagingRequest
from api.v1.proto.project_service_pb2 import (
    ListAllProjectsRequest,
    ListAllProjectsResponse
)

def get_projects(storage_service: StorageService, next_page_token: bytes = None) -> Tuple[List, bytes]:
    """
    Fetch projects from the storage service with pagination support.

    Args:
        storage_service (StorageService): The storage service instance.
        next_page_token (bytes, optional): Token for the next page of results.

    Returns:
        Tuple[List, bytes]: A tuple containing a list of projects and the next page token.
    """
    request = ListAllProjectsRequest(
        paging=PagingRequest(page_size=100, page_token=next_page_token)
    )
    response: ListAllProjectsResponse = storage_service.project_service.ListAllProjects(
        request,
        metadata=(("admin_flag", "true"),)
    )
    return response.project, response.paging.next_page_token

def get_total_deployments(storage_service: StorageService, projects: List) -> int:
    """
    Calculate the total number of deployments for the given projects.

    Args:
        storage_service (StorageService): The storage service instance.
        projects (List): List of projects.

    Returns:
        int: The total number of deployments.
    """
    total_deployments = 0
    for project in projects:
        request = CountDeploymentsRequest(project_id=project.id)
        count_response: CountDeploymentsResponse = storage_service.deployment_service.CountDeployments(
            request,
            metadata=(("admin_flag", "true"),)
        )
        total_deployments += count_response.count
    return total_deployments

def initialize_storage_service() -> StorageService:
    """
    Initialize and return a StorageService instance.

    Returns:
        StorageService: The initialized storage service instance.
    """
    cert_path = "./certs/certificate"
    key_path = "./certs/key"
    ca_path = "./certs/ca"

    return StorageService(
        certificate=open(cert_path).read(),
        key=open(key_path).read(),
        ca=open(ca_path).read(),
        url="localhost:9999"
    )

def main():
    storage_service = initialize_storage_service()
    projects = []
    next_page_token = None

    while True:
        new_projects, next_page_token = get_projects(storage_service, next_page_token)
        projects.extend(new_projects)
        if not next_page_token:
            break

    total_deployments = get_total_deployments(storage_service, projects)
    print(f"Total number of deployments in MLOps: {total_deployments}")


if __name__ == "__main__":
    main()
