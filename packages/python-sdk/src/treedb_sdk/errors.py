from __future__ import annotations

from typing import Any


class TreeDbApiError(Exception):
    """TreeDB API error preserving the stable server error envelope."""

    def __init__(
        self,
        message: str,
        *,
        status: int,
        code: str,
        details: Any | None = None,
        payload: Any | None = None,
        cause: BaseException | None = None,
    ) -> None:
        super().__init__(message)
        self.message = message
        self.status = status
        self.code = code
        self.details = details
        self.payload = payload
        self.__cause__ = cause

    @staticmethod
    def from_response(status: int, payload: Any) -> "TreeDbApiError":
        error = payload.get("error") if isinstance(payload, dict) else None
        if isinstance(error, dict):
            code = str(error.get("code") or "internal_error")
            message = str(error.get("message") or f"TreeDB request failed with status {status}")
            details = error.get("details")
        else:
            code = "internal_error"
            message = f"TreeDB request failed with status {status}"
            details = None
        return TreeDbApiError(message, status=status, code=code, details=details, payload=payload)

    @staticmethod
    def network(message: str, cause: BaseException | None = None) -> "TreeDbApiError":
        return TreeDbApiError(message, status=0, code="network_error", cause=cause)
