/********************************************************************************
 * Copyright (c) 2018 Contributors to the ViewModel project
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * SPDX-License-Identifier: EPL-1.0
 ********************************************************************************/
package hu.bme.mit.inf.viewmodel.language

import com.google.inject.Binder
import com.google.inject.multibindings.Multibinder
import com.google.inject.name.Names
import hu.bme.mit.inf.viewmodel.language.jvmmodel.ViewModelLanguageJvmModelAssociator
import hu.bme.mit.inf.viewmodel.language.linking.ViewModelLinkingService
import hu.bme.mit.inf.viewmodel.language.naming.ViewModelQualifiedNameProvider
import hu.bme.mit.inf.viewmodel.language.scoping.ViewModelImportedNamespaceProvider
import hu.bme.mit.inf.viewmodel.language.typing.ViewModelTypeInferrer
import hu.bme.mit.inf.viewmodel.language.typing.ViewModelTypeInformation
import org.apache.log4j.Logger
import org.eclipse.viatra.query.patternlanguage.emf.GenmodelExtensionLoader
import org.eclipse.viatra.query.patternlanguage.emf.IGenmodelMappingLoader
import org.eclipse.viatra.query.patternlanguage.emf.scoping.CompoundMetamodelProviderService
import org.eclipse.viatra.query.patternlanguage.emf.scoping.IMetamodelProvider
import org.eclipse.viatra.query.patternlanguage.emf.scoping.IMetamodelProviderInstance
import org.eclipse.viatra.query.patternlanguage.emf.scoping.MetamodelProviderService
import org.eclipse.viatra.query.patternlanguage.emf.scoping.ResourceSetMetamodelProviderService
import org.eclipse.viatra.query.patternlanguage.emf.types.EMFPatternLanguageTypeRules
import org.eclipse.viatra.query.patternlanguage.emf.types.EMFTypeInferrer
import org.eclipse.viatra.query.patternlanguage.emf.types.EMFTypeSystem
import org.eclipse.viatra.query.patternlanguage.emf.util.IClassLoaderProvider
import org.eclipse.viatra.query.patternlanguage.emf.util.IErrorFeedback
import org.eclipse.viatra.query.patternlanguage.emf.util.ResourceDiagnosticFeedback
import org.eclipse.viatra.query.patternlanguage.typing.ITypeInferrer
import org.eclipse.viatra.query.patternlanguage.typing.ITypeSystem
import org.eclipse.viatra.query.patternlanguage.typing.PatternLanguageTypeRules
import org.eclipse.viatra.query.patternlanguage.typing.TypeInformation
import org.eclipse.xtext.scoping.IScopeProvider
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import org.eclipse.viatra.query.patternlanguage.emf.util.SimpleClassLoaderProvider

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class ViewModelLanguageRuntimeModule extends AbstractViewModelLanguageRuntimeModule {

	// Required by VIATRA services we host in this RuntimeModule.
	def configureLoggerImplementation(Binder binder) {
		binder.bind(Logger).toInstance(Logger.getLogger(ViewModelLanguageRuntimeModule))
	}

	override bindILinkingService() {
		ViewModelLinkingService
	}

	override configureIScopeProviderDelegate(Binder binder) {
		binder.bind(IScopeProvider).annotatedWith(Names.named(AbstractDeclarativeScopeProvider.NAMED_DELEGATE)).to(
			ViewModelImportedNamespaceProvider)
	}

	override bindIQualifiedNameProvider() {
		ViewModelQualifiedNameProvider
	}

	override bindIDerivedStateComputer() {
		ViewModelLanguageJvmModelAssociator
	}
	
	def void configureIMetamodelProviderInstance(Binder binder) {
		val metamodelProviderBinder = Multibinder.newSetBinder(binder, IMetamodelProviderInstance)
		metamodelProviderBinder.addBinding.to(MetamodelProviderService)
		metamodelProviderBinder.addBinding.to(ResourceSetMetamodelProviderService)
	}

	def Class<? extends IMetamodelProvider> bindIMetamodelProvider() {
		CompoundMetamodelProviderService
	}

	def Class<? extends IGenmodelMappingLoader> bindIGenmodelMappingLoader() {
		GenmodelExtensionLoader
	}
	
	def Class<? extends IClassLoaderProvider> bindIClassLoaderProvider() {
		SimpleClassLoaderProvider
	}

	def Class<? extends IErrorFeedback> bindIErrorFeedback() {
		ResourceDiagnosticFeedback
	}

	def Class<? extends ITypeSystem> bindITypeSystem() {
		EMFTypeSystem
	}

	def Class<? extends PatternLanguageTypeRules> bindPatternLanguageTypeRules() {
		EMFPatternLanguageTypeRules
	}

	def Class<? extends ITypeInferrer> bindITypeInferrer() {
		ViewModelTypeInferrer
	}

	def void configureITypeInferrerDelegate(Binder binder) {
		binder.bind(ITypeInferrer).annotatedWith(Names.named(ViewModelTypeInferrer.TYPE_INFERRER_DELEGATE)).to(
			EMFTypeInferrer)
	}

	def Class<? extends TypeInformation> bindTypeInformation() {
		ViewModelTypeInformation
	}
}
