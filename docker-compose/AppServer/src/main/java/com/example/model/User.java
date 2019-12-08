/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.example.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import org.json.simple.JSONObject;

/**
 *
 * @author chungnt
 */
@Getter
@Setter
@AllArgsConstructor
public class User {

    private int userId;
    private String name;
    private String language;
    private String company;

    public String toResponseString() {
        JSONObject ret = new JSONObject();
        ret.put("userId", userId);
        ret.put("name", name);
        ret.put("language", language);
        ret.put("company", company);
        return ret.toJSONString();
    }
}
