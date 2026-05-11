package com.voiceapp.dto;

import lombok.Data;

@Data
public class GiftResponse {
    private Long id;
    private String name;
    private String icon;
    private Integer price;
    private String type;
    private Integer sortOrder;
}
