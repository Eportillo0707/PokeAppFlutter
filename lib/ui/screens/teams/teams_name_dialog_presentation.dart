part of 'teams_screen.dart';

extension _TeamNameDialogPresentation on _TeamNameDialogState {
  Widget _buildNameDialog(BuildContext context) {
    final es = context.l10n.isSpanish;
    return AlertDialog(
      title: Text(es ? 'Nombre del equipo' : 'Team name'),
      content: Form(
          key: form,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLength: 40,
            validator: (value) => value == null || value.trim().isEmpty
                ? (es ? 'Escribe un nombre' : 'Enter a name')
                : null,
            onFieldSubmitted: (_) => submit(),
          )),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(es ? 'Cancelar' : 'Cancel')),
        FilledButton(onPressed: submit, child: Text(es ? 'Guardar' : 'Save')),
      ],
    );
  }
}
