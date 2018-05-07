package com.yachay.yauth;

import java.util.ArrayList;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

public class CustomYauthProvider implements AuthenticationProvider {

  // private static final String clientId = "openkm";
  // private static final String secret = "openkm";
  private static final String authorization = "Basic b3BlbmttOnNlY3JldF9kZXZfb3Blbmtt";
  private static final String yauth_server = "http://alfa-yauth.yachay.gob.ec";

  @Override
  public Authentication authenticate(Authentication authentication) throws AuthenticationException {

    try {
      RestTemplate http = new RestTemplate();

      UsernamePasswordAuthenticationToken password = (UsernamePasswordAuthenticationToken) authentication;

      HttpHeaders headers = new HttpHeaders();

      headers.add("Authorization", authorization);
      headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

      MultiValueMap<String, String> map = new LinkedMultiValueMap<>();
      map.add("grant_type", "password");
      map.add("redirect_uri", "http://alfa-openkm.yachay.gob.ec");
      map.add("username", authentication.getName());
      map.add("password", password.getCredentials().toString());

      HttpEntity<MultiValueMap<String, String>> entity = new HttpEntity<>(map, headers);
      ResponseEntity<String> response = http.postForEntity(yauth_server + "/oauth/token", entity, String.class);
      
      ObjectMapper mapper = new ObjectMapper();
      JsonNode data = mapper.readTree(response.getBody());
      
      ArrayList<GrantedAuthority> permisos = new ArrayList<>();
      
      String [] scopes = data.get("scope").asText().split(" ");
      
      for(String scope : scopes)
        permisos.add(new SimpleGrantedAuthority(scope.split("\\.")[2].toUpperCase()));
      
      UsernamePasswordAuthenticationToken result = new UsernamePasswordAuthenticationToken(authentication.getName(),
          authentication.getCredentials(), permisos);
      result.setDetails(authentication.getDetails());

      return result;
    } catch (Exception e) {
      throw new BadCredentialsException("Error con los datos enviados.");
    }

  }

  @Override
  public boolean supports(Class<?> authentication) {
    return authentication.equals(UsernamePasswordAuthenticationToken.class);
  }

}
