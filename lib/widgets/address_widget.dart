import 'package:flutter/material.dart';
import 'package:juan_million/models/municipality_model.dart';
import 'package:juan_million/models/province_model.dart';
import 'package:juan_million/models/region_model.dart';
import 'package:juan_million/utlis/app_constants.dart';

typedef DropdownItemBuilder<T> = DropdownMenuItem<T> Function(
    BuildContext context, T value);
typedef SelectedItemBuilder<T> = Widget Function(BuildContext context, T value);

/// takes a generic type T and a nullable value of type T.
String? validateDropdown<T>(T? value) {
  if (value == null) {
    return 'Please select a value';
  }
  return null;
}

class _CustomDropdownView<T> extends StatelessWidget {
  const _CustomDropdownView({
    super.key,
    required this.choices,
    required this.onChanged,
    this.value,
    required this.itemBuilder,
    required this.hint,
    required this.selectedItemBuilder,
    this.validator,
  });

  final List<T> choices;
  final ValueChanged<T?> onChanged;
  final T? value;
  final DropdownItemBuilder<T> itemBuilder;
  final SelectedItemBuilder<T> selectedItemBuilder;
  final Widget hint;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      style: const TextStyle(
        fontFamily: 'Medium',
      ),
      key: ValueKey(choices),
      value: value,
      isExpanded: true,
      items: choices.map((e) => itemBuilder.call(context, e)).toList(),
      hint: hint,
      selectedItemBuilder: (BuildContext context) {
        return choices
            .map((e) => selectedItemBuilder.call(context, e))
            .toList();
      },
      onChanged: onChanged,
      icon: const Icon(
        Icons.expand_more,
      ),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(12)),
      ),
      validator: (T? value) => validator?.call(value),
    );
  }
}

class CustomRegionDropdownView extends StatelessWidget {
  const CustomRegionDropdownView({
    super.key,
    required this.onChanged,
    this.value,
    this.itemBuilder,
  }) : validator = validateDropdown;

  final ValueChanged<Region?> onChanged;
  final Region? value;
  final DropdownItemBuilder<Region>? itemBuilder;
  final String? Function(Region?)? validator;

  @override
  Widget build(BuildContext context) {
    return _CustomDropdownView(
      choices: philippineRegions,
      onChanged: onChanged,
      value: value,
      itemBuilder: (BuildContext context, e) {
        return itemBuilder?.call(context, e) ??
            DropdownMenuItem(
                value: e,
                child: Text(
                  e.regionName,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ));
      },
      hint: const Text('Select Region'),
      selectedItemBuilder: (BuildContext context, Region value) {
        return Text(
          value.regionName,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black,
          ),
        );
      },
      validator: validator,
    );
  }
}

class CustomProvinceDropdownView extends StatelessWidget {
  const CustomProvinceDropdownView({
    super.key,
    required this.provinces,
    required this.onChanged,
    this.value,
    this.itemBuilder,
  }) : validator = validateDropdown;

  final List<Province> provinces;
  final Province? value;
  final ValueChanged<Province?> onChanged;
  final DropdownItemBuilder<Province>? itemBuilder;
  final String? Function(Province?)? validator;

  @override
  Widget build(BuildContext context) {
    return _CustomDropdownView(
        choices: provinces,
        onChanged: onChanged,
        value: value,
        itemBuilder: (BuildContext context, e) {
          return itemBuilder?.call(context, e) ??
              DropdownMenuItem(
                  value: e,
                  child: Text(
                    e.name,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ));
        },
        hint: const Text('Select Province'),
        selectedItemBuilder: (BuildContext context, Province value) {
          return Text(
            value.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
            ),
          );
        },
        validator: validator);
  }
}

class CustomMunicipalityDropdownView extends StatelessWidget {
  const CustomMunicipalityDropdownView({
    super.key,
    required this.municipalities,
    required this.onChanged,
    this.value,
    this.itemBuilder,
  }) : validator = validateDropdown;

  final List<Municipality> municipalities;
  final Municipality? value;
  final ValueChanged<Municipality?> onChanged;
  final DropdownItemBuilder<Municipality>? itemBuilder;
  final String? Function(Municipality?)? validator;

  @override
  Widget build(BuildContext context) {
    return _CustomDropdownView(
      choices: municipalities,
      onChanged: onChanged,
      value: value,
      itemBuilder: (BuildContext context, e) {
        return itemBuilder?.call(context, e) ??
            DropdownMenuItem(
                value: e,
                child: Text(
                  e.name,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ));
      },
      hint: const Text('Select Municipality'),
      selectedItemBuilder: (BuildContext context, Municipality value) {
        return Text(value.name, overflow: TextOverflow.ellipsis);
      },
      validator: validator,
    );
  }
}
