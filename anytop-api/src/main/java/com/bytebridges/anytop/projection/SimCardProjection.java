package com.bytebridges.anytop.projection;

public interface SimCardProjection {

	Long getId();
	
	String getOperator();

	String getSimName();

	Boolean getIsActive();

	Integer getBalance();

}
