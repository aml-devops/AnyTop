package com.bytebridges.anytop.enums;

public enum TxnStatus {

    SUCCESS("00", "Success"),
    FAILED("99", "Failed"),
    PENDING("01", "Pending"),
    TIMEOUT("02", "Timeout"),
    UNKNOWN("03", "Unknown");

    private final String code;
    private final String description;

    TxnStatus(String code, String description) {
        this.code = code;
        this.description = description;
    }

    public String getCode() {
        return code;
    }

    public String getDescription() {
        return description;
    }
}
